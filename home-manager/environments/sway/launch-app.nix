# Sinh binding launcher cho sway tu configs/shortcuts/apps.sway.toml.
# DOC LUC EVAL — sua file do la phai switch + reload sway.
# Chi la `exec beckon "<app>"` TRAN (chi dao 09/08/2026): khong
# sway-beckon.sh, khong workspace-per-app — hanh vi workspace user tu config
# rieng trong sway.d. File sinh ra o ~/.config/sway-nix/launch-app.conf vi
# ~/.config/sway la symlink ca thu muc (xem default.nix).
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.sway.toml);

  modMap = {
    ctrl = "Ctrl";
    super = "Mod4";
    alt = "Mod1";
    shift = "Shift";
  };
  toCombo = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = lib.sublist 0 (n - 1) parts;
    key = builtins.elemAt parts (n - 1);
  in
    lib.concatStringsSep "+" (map (m: modMap.${m}) mods ++ [key]);

  lines =
    map (combo: ''bindsym ${toCombo combo} exec beckon "${data.${combo}}"'')
    (builtins.attrNames data);
in
  ''
    # vim: ft=swayconfig
    # SINH TU configs/shortcuts/apps.sway.toml — dung sua tay file nay.
  ''
  + lib.concatStringsSep "\n" lines
  + "\n"
