# Generates sway launcher bindings from configs/shortcuts/launch-app.toml.
# READ AT EVAL, so editing that file needs a switch plus a reload (Tab+r).
#
# Returns { conf, script }: one bindsym per shortcut calling the script with
# candidate names, then the whole chain. The script asks `beckon resolve`
# whether any candidate is RUNNING: yes -> beckon focus. No -> jump to the
# lowest empty workspace on the CURRENT output (`workspace number N` creates
# N when nothing uses it -- measured headless) and launch there. TOML names
# are FRIENDLY ("Claude") while live windows carry raw ids ("brave-<ext>-Default"),
# so only beckon can map them; the launch leg passes the WHOLE chain.
#
# Workspace scan, measured against a real headless sway tree: every workspace
# node carries `.output`, a workspace is busy when its subtree holds any
# process-bearing node, and a number that exists ONLY empty on another output
# is skipped -- using it would steal focus across outputs.
{lib}: let
  data = builtins.fromTOML (builtins.readFile ../../../../configs/shortcuts/launch-app.toml);

  apps = builtins.attrValues data;

  # App names sit VERBATIM inside swayconfig single quotes. A quote breaks the
  # binding with no warning, so reject it at eval.
  badApps = lib.filter (a: lib.hasInfix "'" a) apps;

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
    map (
      combo: let
        app = data.${combo};
        candidates = lib.concatStringsSep "" (map (c: " '${c}'") (lib.splitString " || " app));
        # Plain strings, not an indented string: the trailing "'" would sit next
        # to the closing '' and ''' is an ESCAPE here, silently unbalancing.
      in
        "bindsym " + toCombo combo + " exec $HOME/.config/sway-nix/launch-app.sh"
        + candidates + " '" + app + "'"
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
    target=$(swaymsg -t get_tree | jq -r '
    	[ .. | objects
    	  | select(.type == "workspace" and .num != null)
    	  | { num, out: .output
    	    , busy: any(.. | objects; has("pid"))
    	    , foc:  any(.. | objects; .focused? == true) } ] as $wss
    	| ($wss[] | select(.foc) | .out) as $mon
    	| first(
    	    range(1; 100)
    	    | . as $n
    	    | [ $wss[] | select(.num == $n) ] as $same
    	    | select(($same | length) == 0
    	         or any($same[]; .out == $mon and (.busy | not)))
    	  )
    ')
    case $target in ""|null) ;; *) swaymsg "workspace number $target" ;; esac
    exec beckon "$full"
  '';
in
  assert lib.assertMsg (badApps == []) ''
    launch-app.nix: ten app chua dau `'`, khong nhung an toan vao config duoc:
      ${lib.concatStringsSep "\n      " badApps}
  ''; {
    conf = ''
      # vim: ft=swayconfig
      # GENERATED from configs/shortcuts/launch-app.toml -- do not edit by hand.
    ''
    + lib.concatStringsSep "\n" lines
    + "\n";
    inherit script;
  }
