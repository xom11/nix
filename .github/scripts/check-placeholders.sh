#!/usr/bin/env bash
#
# Moi truong credential duoi home-manager/dotfiles/ phai la placeholder.
#
# Ly do lop nay ton tai: hook pre-push doi chieu CHINH XAC voi secret that, nen
# no mu voi mot key CHUA co trong apikey.zsh. Ca hai vu ro ri o repo nay deu di
# duong do -- mot key moi, viet thang vao file, trong mot thu muc ma cong cu AI
# ghi vao (dotfiles/ la dich cua mkOutOfStoreSymlink).
#
# Bo .md: la tai lieu, va claude.d/commands/discord.md co y viet
# `export DISCORD_TOKEN="token"` nhu huong dan -- quet vao la bao gia.
#
# Chay tay:  ./.github/scripts/check-placeholders.sh

set -uo pipefail

# Byte-wise, khong phu thuoc locale. awk cua macOS bo cuoc voi
# "multibyte conversion failure" khi gap UTF-8 duoi locale UTF-8, con mawk va
# gawk lai xu ly khac nhau. Repo nay day comment tieng Viet, nen day khong phai
# tinh huong hiem -- va so khop chinh xac von la viec cua byte chu khong phai
# cua ky tu.
export LC_ALL=C

cd "$(dirname "$0")/../.." || exit 1

RULES=".github/scripts/placeholders.awk"
SCOPE="home-manager/dotfiles"

[ -r "$RULES" ] || {
    echo "::error::khong doc duoc $RULES"
    exit 1
}

# ---------------------------------------------------------------------------
# Self-test tren du lieu BIA.
#
# Mot kiem tra khong bao gio bat duoc gi trong y het mot kiem tra dang chan tot.
# Repo nay da co tien le: .gitignore go sai chinh ta nam do rat lau, van trong
# nhu dang bao ve, va khong co gi bao. Cac ca duoi day co dinh hoa dung nhung
# hinh dang da tung lot va nhung hinh dang KHONG duoc bao gia.
# ---------------------------------------------------------------------------
if [ "${1:-}" = "--self-test" ]; then
    fail=0

    # `gitleaks:allow` o cuoi moi dong: day la fixture BIA, nhung no co hinh dang
    # cua mot secret that -- do la toan bo muc dich. Khong danh dau thi job
    # gitleaks se do vi chinh bo test cua lop ben canh.
    must_flag=$(
        cat <<'EOF'
  "apiKey": "abcdef0123456789",  # gitleaks:allow
const AUTH_TOKEN = "Bearer abcdef0123456789";  // gitleaks:allow
password = 'khongphaiplaceholder'  # gitleaks:allow
  token: "abc123def456ghi"  # gitleaks:allow
$env:GH_TOKEN = 'literal123456'  # gitleaks:allow
client_secret = "abcdef0123456789"  # gitleaks:allow
EOF
    )
    n_must=6

    must_pass=$(
        cat <<'EOF'
  "apiKey": "$ROUTER_KEY",
  "apiKey": "{env:ROUTER_KEY}",
  "Authorization": "Bearer {env:PIXELLAB_TOKEN}",
  "maxTokens": 16384,
  "reserveTokens": 20000,
  "used-tokens",
const AUTH_TOKEN = `Bearer ${process.env.ROUTER_KEY ?? ""}`;
      Authorization: AUTH_TOKEN,
config.bind("ep", "spawn --userscript qute-pass --password-only")
  "apiKey": "",
$env:ROUTER_KEY = $env:ROUTER_KEY
  password: "<YOUR_PASSWORD>"
  token = "changeme"
EOF
    )

    got=$(printf '%s\n' "$must_flag" | awk -f "$RULES" - | wc -l | tr -d ' ')
    if [ "$got" -ne "$n_must" ]; then
        echo "::error::self-test: $n_must dong dang le bi bat, chi bat duoc $got"
        printf '%s\n' "$must_flag" | awk -f "$RULES" -
        fail=1
    fi

    if ! printf '%s\n' "$must_pass" | awk -f "$RULES" - >/dev/null; then
        echo "::error::self-test: co dong hop le bi bao gia"
        printf '%s\n' "$must_pass" | awk -f "$RULES" -
        fail=1
    fi

    [ "$fail" -eq 0 ] && echo "OK: self-test $n_must ca phai bat, $(printf '%s\n' "$must_pass" | wc -l | tr -d ' ') ca phai bo qua."
    exit "$fail"
fi

# Chi file dang duoc git theo doi: thu chua track thi chua the ro ri.
files=$(git ls-files -- "$SCOPE" |
    grep -E '\.(json|toml|ya?ml|js|mjs|cjs|ts|lua|py|ps1|nix|sh|conf|rasi)$')

if [ -z "$files" ]; then
    echo "::error::khong tim thay file nao duoi $SCOPE -- kiem tra nay dang khong kiem gi"
    exit 1
fi

# Duong dan co khoang trang se lam vo phep tach tu ben duoi. Noi thang thay vi
# lang le kiem thieu file.
if printf '%s\n' "$files" | grep -q '[[:space:]]'; then
    echo "::error::co duong dan chua khoang trang, script nay chua xu ly duoc"
    printf '%s\n' "$files" | grep '[[:space:]]'
    exit 1
fi

nfiles=$(printf '%s\n' "$files" | wc -l | tr -d ' ')

# shellcheck disable=SC2086
awk -v ci="${GITHUB_ACTIONS:-}" -f "$RULES" $files
rc=$?

if [ "$rc" -eq 0 ]; then
    echo "OK: $nfiles file duoi $SCOPE, khong truong credential nao la literal."
else
    echo ""
    echo "Sua bang cach doc tu bien moi truong thay vi viet thang gia tri:"
    echo "  JSON/TOML  \"apiKey\": \"\$ROUTER_KEY\"   hoac   \"{env:ROUTER_KEY}\""
    echo "  JS/TS      process.env.ROUTER_KEY"
    echo "  PowerShell \$env:ROUTER_KEY"
    echo ""
    echo "Neu gia tri do da tung duoc commit, sua file la CHUA du -- no van nam"
    echo "trong lich su git. Phai rotate key."
fi

exit "$rc"
