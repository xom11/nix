# Generates dconf custom-keybindings from configs/shortcuts/apps.shared.toml.
# READ AT EVAL, so editing that file needs a switch -- unlike mac/Windows, where
# beckon serve reads it live. The path literal is deliberate: dconf is an eval
# product anyway.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/apps.shared.toml);

  modMap = {
    ctrl = "<Ctrl>";
    super = "<Super>";
    alt = "<Alt>";
    shift = "<Shift>";
  };
  # "ctrl+super+alt+b" -> "<Ctrl><Super><Alt>b". Every token but the last is a
  # modifier; the last stays as the keysym.
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
        # First candidate only: this is the label shown in Settings, where the
        # full chain would read like a typo. `command` below keeps the whole
        # string -- that is what actually runs.
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
