#!/usr/bin/env bash
# Sinh lai apps.expected.tsv va README.md tu apps.toml.
#
# CI chay lenh nay roi `git diff --exit-code` -- quen chay la CI do.
#
# LC_ALL=C de table.sort cua Lua la thu tu byte, khop voi builtins.sort cua Nix
# va StrCompare(..., true) cua AHK. Khong co no thi locale quyet dinh thu tu va
# ba parser lech nhau tuy may.
set -euo pipefail
cd "$(dirname "$0")"

export LC_ALL=C
LUA="${LUA:-lua}"

for t in gnome macos sway windows; do
  "$LUA" parse.lua --dump "$t"
done > apps.expected.tsv

"$LUA" parse.lua --readme > README.md
