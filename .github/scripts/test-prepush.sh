#!/usr/bin/env bash
#
# Smoke test cho .githooks/pre-push.
#
# Mọi giá trị ở đây là BỊA. Không bao giờ dùng secret thật để kiểm một thứ in ra
# terminal và chạy trong CI của repo public.
#
# Không cần seam nào trong mã hook: đổi $HOME là mọi đường dẫn nguồn secret trỏ
# vào sandbox. Mỗi ca dựng repo + bare remote riêng nên không ca nào dây sang ca
# khác.
#
# Chạy tay:  ./.github/scripts/test-prepush.sh

set -u

REPO_ROOT=$(cd -- "$(dirname -- "$0")/../.." && pwd)
HOOKS="$REPO_ROOT/.githooks"

# Dài hơn ngưỡng MINLEN của hook, không chứa `$`.
VAL_A='fabricated-alpha-000000000000'
VAL_B='fabricated-beta-111111111111'

pass=0
fail=0

ok() {
    pass=$((pass + 1))
    printf 'ok    %s\n' "$1"
}

bad() {
    fail=$((fail + 1))
    printf 'FAIL  %s\n' "$1"
    if [ -n "${2:-}" ]; then printf '%s\n' "$2" | sed 's/^/        | /'; fi
    if [ -n "${GITHUB_ACTIONS:-}" ]; then printf '::error::test-prepush: %s\n' "$1"; fi
}

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

n=0
R=''
H=''

# $1 = secrets | nosecrets
mkrepo() {
    n=$((n + 1))
    R="$WORK/r$n"
    H="$WORK/h$n"
    mkdir -p "$R" "$H/.config/zsh" "$H/.ssh"

    if [ "$1" = secrets ]; then
        {
            printf 'export FAKE_ALPHA_TOKEN="%s"\n' "$VAL_A"
            printf 'export FAKE_BETA_KEY="%s"\n' "$VAL_B"
        } >"$H/.config/zsh/apikey.zsh"
    fi

    git init -q -b main "$R"
    git init -q --bare "$WORK/remote$n.git"
    git -C "$R" remote add origin "$WORK/remote$n.git"
    git -C "$R" config user.name test
    git -C "$R" config user.email test@example.invalid
    git -C "$R" config commit.gpgsign false
    git -C "$R" config core.hooksPath "$HOOKS"
}

commit() { # $1 = message, đã stage sẵn
    git -C "$R" add -A
    git -C "$R" commit -q -m "$1"
}

push() {
    HOME="$H" \
        XDG_CONFIG_HOME="$H/.config" \
        LOCALAPPDATA= \
        GIT_CONFIG_GLOBAL=/dev/null \
        GIT_CONFIG_SYSTEM=/dev/null \
        git -C "$R" push "$@" 2>&1
}

# --------------------------------------------------------------------------
echo '# 1  push sạch thì đi qua'
mkrepo secrets
echo 'khong co gi o day' >"$R/a.txt"
commit 'them a.txt'
out=$(push origin main)
if [ $? -eq 0 ]; then ok 'push sạch được phép'; else bad 'push sạch bị chặn' "$out"; fi

# --------------------------------------------------------------------------
echo '# 2  thêm rồi xoá trước khi push vẫn bị bắt (ca lõi)'
mkrepo secrets
echo 'khoi dau' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
printf 'token = "%s"\n' "$VAL_A" >"$R/leak.txt"
commit 'them leak.txt'
rm -f "$R/leak.txt"
commit 'xoa leak.txt'
# diff tổng giờ đã sạch -- đây là chỗ `git diff` sẽ bỏ sót
if git -C "$R" diff "origin/main..HEAD" | grep -qF "$VAL_A"; then
    bad 'tiền đề sai: diff tổng vẫn còn giá trị, ca kiểm không chứng minh được gì'
else
    ok 'tiền đề đúng: diff tổng đã sạch'
fi
out=$(push origin main)
if [ $? -ne 0 ]; then ok 'add-rồi-delete bị chặn'; else bad 'add-rồi-delete LỌT' "$out"; fi
case "$out" in
*FAKE_ALPHA_TOKEN*) ok 'có in tên biến' ;;
*) bad 'không in tên biến' "$out" ;;
esac
case "$out" in
*"$VAL_A"*) bad 'output CÓ CHỨA giá trị secret' ;;
*) ok 'output không chứa giá trị' ;;
esac

# --------------------------------------------------------------------------
echo '# 3  giá trị nằm trong commit message'
mkrepo secrets
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
echo 'y' >>"$R/a.txt"
commit "vo tinh dan vao message: $VAL_B"
out=$(push origin main)
if [ $? -ne 0 ]; then ok 'commit message bị chặn'; else bad 'commit message LỌT' "$out"; fi

# --------------------------------------------------------------------------
echo '# 4  branch mới (remote sha toàn 0)'
mkrepo secrets
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
git -C "$R" checkout -q -b feature
printf 'k = "%s"\n' "$VAL_A" >"$R/leak.txt"
commit 'leak tren branch moi'
out=$(push origin feature)
if [ $? -ne 0 ]; then ok 'branch mới bị chặn'; else bad 'branch mới LỌT' "$out"; fi

# --------------------------------------------------------------------------
echo '# 5  xoá branch trên remote (local sha toàn 0)'
mkrepo secrets
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
git -C "$R" checkout -q -b tmpbranch
echo 'y' >>"$R/a.txt"
commit 'them'
out=$(push origin tmpbranch)
out=$(push origin --delete tmpbranch)
if [ $? -eq 0 ]; then ok 'xoá branch được phép'; else bad 'xoá branch bị chặn' "$out"; fi

# --------------------------------------------------------------------------
echo '# 6  máy CÓ tên trong authorized_keys mà không lấy được secret -> chặn'
mkrepo nosecrets
ssh-keygen -q -t ed25519 -N '' -f "$H/.ssh/id_ed25519" -C test
mkdir -p "$R/home-manager/programs/ssh"
awk '{ print }' "$H/.ssh/id_ed25519.pub" >"$R/home-manager/programs/ssh/authorized_keys"
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
if [ $? -ne 0 ]; then ok 'recipient thiếu secret bị chặn'; else bad 'recipient thiếu secret LỌT' "$out"; fi
case "$out" in
*authorized_keys*) ok 'thông báo chỉ đúng nguyên nhân' ;;
*) bad 'thông báo không nhắc authorized_keys' "$out" ;;
esac

# --------------------------------------------------------------------------
echo '# 7  máy KHÔNG có tên trong authorized_keys -> cho qua kèm ghi chú'
mkrepo nosecrets
ssh-keygen -q -t ed25519 -N '' -f "$H/.ssh/id_ed25519" -C test
ssh-keygen -q -t ed25519 -N '' -f "$WORK/other$n" -C other
mkdir -p "$R/home-manager/programs/ssh"
awk '{ print }' "$WORK/other$n.pub" >"$R/home-manager/programs/ssh/authorized_keys"
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
if [ $? -eq 0 ]; then ok 'không phải recipient thì được phép'; else bad 'không phải recipient bị chặn' "$out"; fi
case "$out" in
*'không giữ secret'*) ok 'có in ghi chú' ;;
*) bad 'không in ghi chú' "$out" ;;
esac

# --------------------------------------------------------------------------
echo '# 8  diff có UTF-8 không làm bộ quét chết giữa chừng'
# Repo này đầy comment tiếng Việt. awk của macOS bỏ cuộc với "multibyte
# conversion failure" dưới locale UTF-8, và một bộ quét chết giữa chừng thì
# trông y hệt một repo sạch.
mkrepo secrets
printf 'Đường dẫn tuyệt đối — hàng rào không tự hạ.\n' >"$R/tiengviet.txt"
commit 'commit goc co dau'
out=$(push origin main)
if [ $? -eq 0 ]; then ok 'UTF-8 vô hại thì đi qua'; else bad 'UTF-8 vô hại bị chặn' "$out"; fi
printf 'Ghi chú tiếng Việt kèm khoá: %s\n' "$VAL_A" >"$R/leak.txt"
commit 'them leak canh utf-8'
out=$(push origin main)
if [ $? -ne 0 ]; then ok 'vẫn bắt được key nằm cạnh UTF-8'; else bad 'UTF-8 làm bộ quét mù' "$out"; fi

# --------------------------------------------------------------------------
echo '# 9  chỉ dọn dẹp (giá trị chỉ xuất hiện ở dòng bị XOÁ) thì đi qua'
# Giá trị đã được push từ trước, tức là đã public. Chặn commit gỡ nó đi không
# bảo vệ thêm gì, chỉ chặn đúng cái commit đang dọn. Hook từng làm thế thật.
mkrepo secrets
printf 'k = "%s"\n' "$VAL_A" >"$R/leak.txt"
commit 'commit goc da co key'
out=$(push --no-verify origin main) # giả lập "đã lỡ public từ trước"
rm -f "$R/leak.txt"
commit 'don dep: go leak.txt'
out=$(push origin main)
if [ $? -eq 0 ]; then ok 'commit dọn dẹp được phép'; else bad 'commit dọn dẹp bị chặn' "$out"; fi

# --------------------------------------------------------------------------
echo '# 10  allow-vars miễn trừ đúng biến được liệt kê, và chỉ biến đó'
mkrepo secrets
echo 'x' >"$R/a.txt"
commit 'commit goc'
out=$(push origin main)
# allow-vars của repo thật không chứa biến bịa, nên dựng một .githooks riêng
CLONE="$WORK/hooks$n"
cp -R "$HOOKS" "$CLONE"
printf '# bia\nFAKE_ALPHA_TOKEN\n' >"$CLONE/allow-vars"
git -C "$R" config core.hooksPath "$CLONE"
printf 'a = "%s"\n' "$VAL_A" >"$R/leak.txt"
commit 'them bien duoc mien tru'
out=$(push origin main)
if [ $? -eq 0 ]; then ok 'biến trong allow-vars được bỏ qua'; else bad 'allow-vars không có tác dụng' "$out"; fi
# ...và biến KHÔNG được liệt kê vẫn phải bị chặn, nếu không thì cơ chế này chỉ là
# một công tắc tắt hàng rào.
printf 'b = "%s"\n' "$VAL_B" >"$R/leak2.txt"
commit 'them bien khong duoc mien tru'
out=$(push origin main)
if [ $? -ne 0 ]; then ok 'biến ngoài allow-vars vẫn bị chặn'; else bad 'allow-vars làm mù cả biến khác' "$out"; fi
case "$out" in
*FAKE_BETA_KEY*) ok 'chặn đúng biến còn lại' ;;
*) bad 'không nêu đúng biến' "$out" ;;
esac

# --------------------------------------------------------------------------
printf '\n%s\n' "-----------------------------------------"
printf 'pass=%s fail=%s\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
