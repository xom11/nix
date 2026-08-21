# Generates hyprland launcher bindings from configs/shortcuts/launch-app.toml.
# READ AT EVAL, so editing that file needs a switch plus a reload.
# Plain `exec beckon "<app>"`, no workspace logic -- that belongs to hypr.d.
# Emitted into ~/.config/hypr-nix/ because ~/.config/hypr is a whole-directory
# symlink.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/launch-app.toml);

  apps = builtins.attrValues data;

  # App names are embedded VERBATIM into a double-quoted shell string, which is
  # itself inside a Lua long-bracket string. These two characters break one layer
  # or the other with no warning, so reject them at eval.
  badApps = lib.filter (a: lib.hasInfix "]]" a || lib.hasInfix ''"'' a) apps;

  modMap = {
    ctrl = "CTRL";
    super = "SUPER";
    alt = "ALT";
    shift = "SHIFT";
  };

  # "ctrl+super+alt+b" -> "CTRL + SUPER + ALT + b". Every token but the last is a
  # modifier; the last stays as the keysym. `hl.bind` splits on PLUS, not spaces.
  toBind = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = map (m: modMap.${m}) (lib.sublist 0 (n - 1) parts);
    key = builtins.elemAt parts (n - 1);
  in
    lib.concatStringsSep " + " (mods ++ [key]);

  lines =
    map (combo: ''hl.bind("${toBind combo}", hl.dsp.exec_cmd([[beckon "${data.${combo}}"]]))'')
    (builtins.attrNames data);
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua `]]` hoac `"`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  '';
    ''
      -- SINH TU configs/shortcuts/launch-app.toml — dung sua tay file nay.
    ''
    + lib.concatStringsSep "\n" lines
    + "\n"
