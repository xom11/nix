# Generates hyprland launcher bindings from configs/shortcuts/launch-app.toml.
# READ AT EVAL, so editing that file needs a switch plus a reload.
#
# Each binding asks `beckon resolve` (~4 ms) whether any candidate is RUNNING:
# yes -> plain beckon focus. No -> jump to the lowest empty workspace on the
# CURRENT monitor (`hyprctl dispatch 'hl.dsp.focus{...}'`;
# `dsp.workspace.change_id` RENAMES a workspace, it does not switch) and launch
# there. Windows opened by anything else stay put -- the old global windowrule
# moved EVERY new window and was removed for exactly that.
#
# TOML names are FRIENDLY ("Claude"), while live windows carry raw ids
# ("brave-<ext>-Default"); only beckon knows that mapping, hence resolve here
# instead of matching classes in Lua. The launch leg passes the WHOLE chain so
# beckon keeps its own left-to-right resolution.
#
# Emitted into ~/.config/hypr-nix/ because ~/.config/hypr is a whole-directory
# symlink.
{
  lib,
}: let
  data = builtins.fromTOML (builtins.readFile ../../../../configs/shortcuts/launch-app.toml);

  apps = builtins.attrValues data;

  # App names sit VERBATIM inside a Lua [==[ long bracket AND shell single
  # quotes. These two characters break one layer or the other with no warning,
  # so reject them at eval.
  badApps = lib.filter (a: lib.hasInfix "]]" a || lib.hasInfix "'" a) apps;

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
    map (
      combo: let
        app = data.${combo};
        candidates = lib.concatStringsSep " " (
          map (c: "'${c}'") (lib.splitString " || " app)
        );
      in
        ''
          hl.bind("${toBind combo}", hl.dsp.exec_cmd([==[
          	run=""
          	for c in ${candidates}; do
          		beckon resolve "$c" 2>/dev/null | grep -qE 'Status: *running' && run="$c" && break
          	done
          	if [ -n "$run" ]; then exec beckon "$run"; fi
          	hyprctl dispatch 'hl.dsp.focus({ workspace = [[emptym]], on_current_monitor = true })'
          	exec beckon '${app}'
          ]==]))
        ''
    )
    (builtins.attrNames data);
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua `]]` hoac `'`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  '';
    ''
      -- SINH TU configs/shortcuts/launch-app.toml — dung sua tay file nay.
    ''
    + lib.concatStringsSep "\n" lines
    + "\n"
