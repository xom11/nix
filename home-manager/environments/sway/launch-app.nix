# Generates sway launcher bindings from configs/shortcuts/apps.shared.toml.
# READ AT EVAL, so editing that file needs a switch plus a sway reload.
# Plain `exec beckon "<app>"`: no wrapper script and no workspace-per-app, which
# is configured separately in sway.d. Emitted into ~/.config/sway-nix/ because
# ~/.config/sway is a whole-directory symlink.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

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
    # GENERATED from configs/shortcuts/apps.shared.toml -- do not edit by hand.
  ''
  + lib.concatStringsSep "\n" lines
  + "\n"
