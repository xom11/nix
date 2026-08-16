# Sinh binding launcher cho hyprland tu configs/shortcuts/apps.shared.toml.
# DOC LUC EVAL — sua file do la phai switch + Tab+r (hyprctl reload).
# Chi la `exec beckon "<app>"` tran, khong workspace logic — hanh vi workspace
# la viec rieng cua hypr.d. File sinh ra o ~/.config/hypr-nix/launch-app.conf
# vi ~/.config/hypr la symlink ca thu muc (xem default.nix).
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

  modMap = {
    ctrl = "CTRL";
    super = "SUPER";
    alt = "ALT";
    shift = "SHIFT";
  };
  # "ctrl+super+alt+b" -> "CTRL SUPER ALT, b". Modifier la moi token truoc
  # token cuoi; token cuoi giu nguyen (hyprland nhan keysym: b, space, ...).
  toBind = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = lib.sublist 0 (n - 1) parts;
    key = builtins.elemAt parts (n - 1);
  in
    lib.concatStringsSep " " (map (m: modMap.${m}) mods) + ", " + key;

  lines =
    map (combo: ''bind = ${toBind combo}, exec, beckon "${data.${combo}}"'')
    (builtins.attrNames data);
in
  ''
    # vim: ft=hyprlang
    # SINH TU configs/shortcuts/apps.shared.toml — dung sua tay file nay.
  ''
  + lib.concatStringsSep "\n" lines
  + "\n"
