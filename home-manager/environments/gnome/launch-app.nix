# Sinh dconf custom-keybindings tu configs/shortcuts/apps.shared.toml.
# DOC LUC EVAL (fromTOML): sua file la phai `home-manager switch` — khac han
# mac/windows (beckon serve doc luc chay). Path literal o day la CO Y:
# dconf von la san pham cua eval.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

  modMap = {
    ctrl = "<Ctrl>";
    super = "<Super>";
    alt = "<Alt>";
    shift = "<Shift>";
  };
  # "ctrl+super+alt+b" -> "<Ctrl><Super><Alt>b". Modifier la moi token truoc
  # token cuoi; token cuoi giu nguyen (dconf nhan keysym: b, space, ...).
  toBinding = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = lib.sublist 0 (n - 1) parts;
    key = builtins.elemAt parts (n - 1);
  in
    lib.concatStrings (map (m: modMap.${m}) mods) + key;

  base = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings";

  entries =
    lib.imap0 (i: combo: {
      name = "${base}/custom${toString i}";
      value = {
        # Chi ung vien DAU, khong ca chuoi: day la ten hien trong
        # Settings -> Keyboard, va "Beckon kitty || Terminal" doc nhu mot loi
        # danh may. `command` ben duoi van mang ca chuoi — do moi la thu chay.
        name = "Beckon ${lib.strings.trim (lib.head (lib.splitString "||" data.${combo}))}";
        binding = toBinding combo;
        command = ''beckon "${data.${combo}}"'';
      };
    })
    (builtins.attrNames data);
in
  {
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings =
      map (e: "/${e.name}/") entries;
  }
  // lib.listToAttrs entries
