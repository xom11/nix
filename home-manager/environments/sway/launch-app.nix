# Sinh phan binding launcher cho sway tu configs/shortcuts/apps.toml.
#
# swayconfig khong co vong lap nen day la file duy nhat trong bo nay bat buoc
# phai sinh ra. No KHONG nam trong sway.d/: ~/.config/sway la mot symlink
# out-of-store tro vao ca thu muc do, nen home-manager khong dat them file vao
# ben trong duoc. Vi vay no di ra ~/.config/sway-nix/ va sway.d/config
# `include` no.
#
# $cap va $focus phai duoc dinh nghia TRUOC: $cap o sway.d/config dong 4,
# $focus o sway.d/conf.d/launch-app.conf -- nen dong include phai nam sau
# `include conf.d/*.conf`.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.toml);

  idFor = e:
    if builtins.hasAttr "sway" e
    then e.sway
    else e.id;

  rows =
    map (e: {
      inherit (e) key;
      id = idFor e;
      mods = "$cap";
    })
    (data.app or [])
    ++ map (e: {
      inherit (e) key;
      id = idFor e;
      mods = "$cap+Shift";
    })
    (data.shift or []);

  bound = builtins.filter (r: r.id != "") rows;

  line = r: ''bindsym ${r.mods}+${r.key} $focus "${r.id}"'';
in ''
  # vim: ft=swayconfig
  #
  # SINH RA TU configs/shortcuts/apps.toml -- DUNG SUA TAY.
  # Sua o apps.toml roi `home-manager switch`.

  ${lib.concatMapStringsSep "\n" line bound}
''
