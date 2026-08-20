#!/usr/bin/env bash
#
# Every credential field under home-manager/dotfiles/ must be a placeholder.
#
# This layer exists because the pre-push hook compares EXACTLY against real
# secrets, so it is blind to a key not yet in apikey.zsh. Both leaks in this repo
# took that route: a new key written straight into a file, in a directory AI tools
# write to.
#
# .md is excluded: it is documentation, and one command file deliberately shows
# `export DISCORD_TOKEN="token"` as an example.
#
# Run by hand:  ./.github/scripts/check-placeholders.sh

set -uo pipefail

# Byte-wise and locale-independent: macOS awk aborts with "multibyte conversion
# failure" on UTF-8 under a UTF-8 locale, and mawk and gawk differ again. Exact
# matching is a byte question, not a character one, anyway.
export LC_ALL=C

cd "$(dirname "$0")/../.." || exit 1

RULES=".github/scripts/placeholders.awk"
SCOPE="home-manager/dotfiles"

[ -r "$RULES" ] || {
    echo "::error::khong doc duoc $RULES"
    exit 1
}

# Self-test on FABRICATED data.
#
# A check that never catches anything looks exactly like a check that is working.
# This repo has the precedent: a misspelled .gitignore line sat there for a long
# time looking protective. These cases pin both the shapes that once slipped
# through and the shapes that must NOT raise a false alarm.
if [ "${1:-}" = "--self-test" ]; then
    fail=0

    # `gitleaks:allow` per line: these fixtures are fabricated but shaped like
    # real secrets, which is the point -- unmarked, they would fail the gitleaks
    # job with this layer's own tests.
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

# Tracked files only: nothing untracked can have leaked yet.
files=$(git ls-files -- "$SCOPE" |
    grep -E '\.(json|toml|ya?ml|js|mjs|cjs|ts|lua|py|ps1|nix|sh|conf|rasi)$')

if [ -z "$files" ]; then
    echo "::error::khong tim thay file nao duoi $SCOPE -- kiem tra nay dang khong kiem gi"
    exit 1
fi

# A path with a space would break the word splitting below. Say so rather than
# silently checking fewer files.
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
