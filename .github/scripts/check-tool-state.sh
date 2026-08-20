#!/usr/bin/env bash
#
# Keep local AI/dev tool state out of a public repo.
#
# Two checks, and the second is why this file exists:
#   1. Nothing under those directories is tracked by git.
#   2. .gitignore ACTUALLY matches them.
#
# (1) alone is not enough: a misspelled .gitignore line still sits there looking
# protective while matching nothing, and git will never tell you. A clean repo
# today may just mean nobody has created a file there yet.
#
# Not hypothetical: `.anitigravitycli/` (one extra `i`) sat in this .gitignore for
# a long time while `.antigravitycli/` was published. Check (2) catches that
# before anything is committed.
#
# Run by hand:  ./.github/scripts/check-tool-state.sh

set -uo pipefail

DIRS=(
    .claude
    .antigravitycli
    .codegraph
    .gemini
    .gstack
    .superpowers
    docs/superpowers
)

fail=0

for d in "${DIRS[@]}"; do
    tracked=$(git ls-files -- "$d")
    if [ -n "$tracked" ]; then
        fail=1
        echo "::error::'$d' dang duoc git theo doi. Go bang: git rm -r --cached '$d'"
        echo "$tracked" | head -5 | sed 's/^/    /'
        n=$(echo "$tracked" | wc -l | tr -d ' ')
        if [ "$n" -gt 5 ]; then echo "    ... va $((n - 5)) file nua"; fi
    fi

    # Ask about a child path rather than the directory: a `dir/` rule only matches
    # directories, and this works even when the directory does not exist on disk --
    # on a fresh CI checkout most of them do not.
    if ! git check-ignore -q "$d/.probe"; then
        fail=1
        echo "::error::'$d' KHONG duoc .gitignore khop -- kiem lai chinh ta trong .gitignore"
    fi
done

if [ "$fail" -eq 0 ]; then
    echo "OK: ${#DIRS[@]} thu muc trang thai cong cu, deu bi ignore va deu khong tracked."
fi

exit "$fail"
