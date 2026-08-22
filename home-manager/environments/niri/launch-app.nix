# Generates niri launcher bindings from configs/shortcuts/launch-app.toml.
# READ AT EVAL, so editing that file needs a switch. niri also live-reloads the
# generated file, so once switched in, further TOML edits need ONLY another
# switch -- no Tab+r, no session restart (unlike sway/hyprland).
#
# Each bind spawns the script DIRECTLY with candidates as separate argv entries:
# niri's plain `spawn` execve's without a shell, so nothing inside the names
# needs shell quoting. The assert below rejects what WOULD break it -- `"` and
# `\`, the two KDL escape characters -- where sway's version rejects `'`
# because its exec goes through a shell.
#
# The script asks `beckon resolve` (~4 ms) whether any candidate is RUNNING:
# yes -> plain beckon focus. No -> focus the first empty workspace on the
# focused output (niri always keeps an empty workspace at the end of each
# output) and launch there. Windows opened by anything else stay put -- same
# shape as sway/hyprland after their global move-every-new-window rules were
# removed.
#
# Lands in ~/.config/niri-nix/ because ~/.config/niri is a whole-directory
# symlink into the repo.
{
  lib,
  homeDir,
}: let
  data = builtins.fromTOML (builtins.readFile ../../../configs/shortcuts/launch-app.toml);

  apps = lib.flatten (map (a: lib.splitString " || " a) (builtins.attrValues data));

  badApps = lib.filter (a: lib.hasInfix "\"" a || lib.hasInfix "\\" a) apps;

  modMap = {
    ctrl = "Ctrl";
    super = "Mod";
    alt = "Alt";
    shift = "Shift";
  };

  # Binds spell letters uppercase (`Mod+T`) and word keysyms Title-case (`Space`).
  toKey = k:
    if k == "space"
    then "Space"
    else if builtins.stringLength k == 1
    then lib.toUpper k
    else k;

  toBind = combo: let
    parts = lib.splitString "+" combo;
    n = builtins.length parts;
    mods = map (m: modMap.${m}) (lib.sublist 0 (n - 1) parts);
    # Hoisted because [f (x)] inside a list is TWO elements -- the bare
    # function plus the arg -- which concatStringsSep then chokes on.
    key = toKey (builtins.elemAt parts (n - 1));
  in
    lib.concatStringsSep "+" (mods ++ [key]);

  lines =
    map (
      combo: let
        app = data.${combo};
        args = lib.concatStringsSep " " (
          map (c: "\"${c}\"") ((lib.splitString " || " app) ++ [app])
        );
      in ''${toBind combo} hotkey-overlay-title="Launcher: ${app}" { spawn "${homeDir}/.config/niri-nix/launch-app.sh" ${args}; }''
    )
    (builtins.attrNames data);

  script = ''
    #!/usr/bin/env bash
    # SINH TU configs/shortcuts/launch-app.toml — dung sua tay file nay.
    # args: candidate... full-chain
    full="''${*: -1}"
    for c in ''${@:1:$#-1}; do
    	beckon resolve "$c" 2>/dev/null | grep -qE 'Status: *running' && exec beckon "$c"
    done
    id=$(niri msg -j workspaces | jq -r '
    	([.[] | select(.is_focused)][0].output) as $out
    	| first(.[] | select(.output == $out and .active_window_id == null) | .id)')
    case $id in ""|null) ;; *) niri msg action focus-workspace --id "$id" ;; esac
    exec beckon "$full"
  '';
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua `"` hoac `\`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  ''; {
    # The included file is spliced at TOP LEVEL, so unlike sway/hyprland the
  # binds need their own `binds` section -- niri merges repeat sections,
  # later definitions winning.
  conf = ''
    // GENERATED from configs/shortcuts/launch-app.toml -- do not edit by hand.
    binds {
${lib.concatStringsSep "\n" (map (l: "    " + l) lines)}
    }
  '';
    inherit script;
  }
