# Duong Nix cua cung mot phep khai trien ma parse.lua va parse.ahk lam. Chi
# dung cho CI: so voi apps.expected.tsv de chac ba parser khong lech nhau.
#
#   nix eval --impure --raw --expr \
#     'import ./configs/shortcuts/dump.nix { target = "gnome"; }'
#
# Sap xep CA DONG hoan chinh, giong parse.lua -- vi tien to "<target>\t<lop>\t"
# co dinh trong mot lan goi nen sap chuoi la ra dung thu tu lop roi phim,
# va "app" < "shift".
{target}: let
  data = builtins.fromTOML (builtins.readFile ./apps.toml);

  idFor = e:
    if builtins.hasAttr target e
    then builtins.getAttr target e
    else e.id;

  rowsOf = entries: layer:
    builtins.filter (r: r != null)
    (map (e: let
      id = idFor e;
    in
      if id == ""
      then null
      else "${target}\t${layer}\t${e.key}\t${id}")
    entries);

  rows = rowsOf data.app "app" ++ rowsOf data.shift "shift";
in
  builtins.concatStringsSep "\n" (builtins.sort (a: b: a < b) rows) + "\n"
