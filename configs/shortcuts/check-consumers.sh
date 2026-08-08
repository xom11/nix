#!/usr/bin/env bash
# Kiem hai module tieu thu (gnome, sway) co con khop apps.toml khong.
#
# parse.lua / parse.ahk / dump.nix deu duoc CI so voi apps.expected.tsv. Hai
# module duoi day thi TU CAI LAI cung phep resolve do, nen chung co the lech ma
# khong gi bao. Script nay bien ket qua cuoi cung cua chung ve dung dinh dang
# golden roi diff -- kiem OUTPUT chu khong kiem code, nen no bat ca truong hop
# rule dung ma phan phat sinh lam rot mat entry.
set -euo pipefail
cd "$(dirname "$0")/../.."
export LC_ALL=C

LIB='(import <nixpkgs> {}).lib'
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
rc=0

# gnome: attrset dconf -> target/lop/phim/id
nix eval --impure --json --expr \
  "import ./home-manager/environments/gnome/launch-app.nix { lib = $LIB; }" \
| jq -r '
    to_entries[]
    | select(.key | test("custom-keybindings/custom[0-9]+$"))
    | .value
    | (if (.binding | startswith("<Ctrl><Super><Alt><Shift>"))
       then "shift" else "app" end) as $layer
    | (.binding | sub("^<Ctrl><Super><Alt>(<Shift>)?"; "")) as $key
    | (.command | sub("^beckon \""; "") | sub("\"$"; "")) as $id
    | ["gnome", $layer, $key, $id] | @tsv
  ' | sort > "$tmp/gnome.got"
grep '^gnome' configs/shortcuts/apps.expected.tsv | sort > "$tmp/gnome.want"
diff "$tmp/gnome.want" "$tmp/gnome.got" || { echo "gnome/launch-app.nix lech golden"; rc=1; }

# sway: text swayconfig -> target/lop/phim/id
nix eval --impure --raw --expr \
  "import ./home-manager/environments/sway/launch-app.nix { lib = $LIB; }" \
| sed -n \
  -e 's/^bindsym \$cap+Shift+\([^ ]*\) \$focus "\(.*\)"$/sway\tshift\t\1\t\2/p' \
  -e 's/^bindsym \$cap+\([^ +]*\) \$focus "\(.*\)"$/sway\tapp\t\1\t\2/p' \
| sort > "$tmp/sway.got"
grep '^sway' configs/shortcuts/apps.expected.tsv | sort > "$tmp/sway.want"
diff "$tmp/sway.want" "$tmp/sway.got" || { echo "sway/launch-app.nix lech golden"; rc=1; }

[ $rc -eq 0 ] && echo "HAI MODULE TIEU THU KHOP GOLDEN"
exit $rc
