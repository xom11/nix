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
  # Target khong con binding nao thi phai ra CHUOI RONG, khong phai "\n".
  # parse.lua lam dung the (`if d ~= "" then print(d) end`) va parse.ahk cung
  # vay (dump rong -> FileAppend khong ghi gi). Neu cho concatStringsSep chay
  # tren list rong roi + "\n" thi Nix ra 1 byte con hai ban kia ra 0 byte:
  # du lieu hom nay khong kich hoat duoc vi ca bon target deu co binding, nen
  # golden van xanh va bug nam cho toi khi ai do rut het override cua mot
  # target hoac them target thu nam.
  if rows == []
  then ""
  else builtins.concatStringsSep "\n" (builtins.sort (a: b: a < b) rows) + "\n"
