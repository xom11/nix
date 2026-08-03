# Đối chiếu giá trị secret thật với patch của từng commit sắp được push.
#
# Đầu vào là MỘT luồng duy nhất, để không có plaintext nào phải đi qua đĩa hay
# qua argv:
#
#     <các dòng secret>          pha nạp
#     <mark>                     ranh giới
#     <output của git log -p>    pha quét
#
# Đầu ra: mỗi phát hiện một dòng, `TÊN_BIẾN <TAB> sha <TAB> đường dẫn`.
# KHÔNG BAO GIỜ in giá trị -- thông báo phải nói được chuyện gì xảy ra mà không
# tự nó trở thành một lần rò rỉ nữa.
#
# Thoát 1 nếu có phát hiện, 0 nếu sạch.

BEGIN {
    loading = 1
    nhit    = 0
    nval    = 0
    sha     = "?"
    path    = ""
    indiff  = 0

    # Tên biến được miễn trừ, đọc từ .githooks/allow-vars. Chỉ là TÊN nên truyền
    # qua -v thoải mái; giá trị thì không bao giờ đi lối này.
    na = split(allow, a, /[ \t,]+/)
    for (ia = 1; ia <= na; ia++)
        if (a[ia] != "") skip[a[ia]] = 1
}

# apikey.ps1 được ghi trên Windows nên là CRLF; git log thì không. Cắt ở đây một
# lần cho cả hai pha.
{ sub(/\r$/, "") }

loading && $0 == mark { loading = 0; next }

# ---------------------------------------------------------------- pha nạp ----
#
# Hai cú pháp, cùng một parser:
#     export K="V"   /   K="V"      (~/.config/zsh/apikey.zsh, zsh source thẳng)
#     $env:K = 'V'                  (%LOCALAPPDATA%\pwsh-secrets\apikey.ps1)
loading {
    line = $0
    sub(/^[ \t]+/, "", line)
    if (line == "" || line ~ /^#/) next

    sub(/^export[ \t]+/, "", line)
    sub(/^\$env:/, "", line)

    eq = index(line, "=")
    if (eq == 0) next

    name = substr(line, 1, eq - 1)
    v    = substr(line, eq + 1)

    sub(/[ \t]+$/, "", name)
    if (name !~ /^[A-Za-z_][A-Za-z0-9_]*$/) next
    if (name in skip) next

    sub(/^[ \t]+/, "", v)
    sub(/[ \t]+$/, "", v)
    if (v ~ /^".*"$/ || v ~ /^'.*'$/) v = substr(v, 2, length(v) - 2)

    # Giá trị tham chiếu biến khác không phải secret, và ghép nó vào sẽ khớp mọi
    # diff có nhắc tới đường dẫn đó. CLAUDE.md đã cấm `$` trong giá trị secret vì
    # lý do khác (zsh và parser PowerShell bất đồng về nội suy), nên bỏ qua ở đây
    # không mất gì.
    if (v ~ /\$[A-Za-z_{(]/) next

    # Ngưỡng là CHÍNH SÁCH viết thẳng trong mã, không phải số đo lấy từ dữ liệu
    # sống. Giá trị quá ngắn sẽ khớp gần như mọi diff, và một hook lúc nào cũng
    # đỏ là một hook sắp bị vô hiệu hoá.
    if (length(v) < minlen) next

    if (!(name in val)) nval++
    val[name] = v
    next
}

# --------------------------------------------------------------- pha quét ----
{
    # Bám vết commit và file để thông báo chỉ được đúng chỗ. `--pretty=medium
    # --no-decorate` được ép ở phía gọi, nên dòng tiêu đề luôn đúng hình dạng này
    # bất kể máy có đặt `format.pretty` hay `log.decorate` gì.
    if ($0 ~ /^commit [0-9a-fA-F]+$/) {
        sha    = substr($0, 8)
        path   = ""
        indiff = 0
    } else if ($0 ~ /^diff --cc /) {
        path   = substr($0, 11)
        indiff = 1
    } else if ($0 ~ /^diff --git /) {
        path   = ""
        indiff = 1
    } else if ($0 ~ /^\+\+\+ /) {
        p = substr($0, 5)
        sub(/\t.*$/, "", p)
        if (p ~ /^b\//) p = substr(p, 3)
        if (p != "/dev/null") path = p
    }

    # Trong phần diff chỉ soi dòng THÊM. Một dòng `-` nghĩa là giá trị đó đã nằm ở
    # một commit trước:
    #   - commit đó nằm TRONG range  -> dòng `+` của nó đã bị bắt rồi
    #   - commit đó nằm NGOÀI range  -> nó đã được push, tức là đã public
    # Cả hai trường hợp, chặn ở dòng xoá không bảo vệ thêm được gì -- nó chỉ chặn
    # đúng cái commit đang dọn dẹp. Hook này đã tự chặn commit sửa
    # 9router-tools.ts vì lý do đó.
    #
    # Phần commit message (indiff == 0) thì soi hết: CLAUDE.md coi commit message
    # là một lần publish.
    if (indiff && $0 !~ /^\+/) next

    for (k in val) {
        if (index($0, val[k]) > 0) {
            where = (path == "" ? "(commit message)" : path)
            id = k SUBSEP sha SUBSEP where
            if (!(id in seen)) {
                seen[id] = 1
                nhit++
                printf "%s\t%s\t%s\n", k, sha, where
            }
        }
    }
}

END {
    # Đọc được nguồn secret mà không rút ra được giá trị nào là hàng rào hỏng chứ
    # không phải hàng rào sạch. Nói ra, đừng im.
    if (nval == 0)
        print "pre-push: khong rut duoc gia tri nao tu nguon secret" > "/dev/stderr"
    exit (nhit > 0 ? 1 : 0)
}
