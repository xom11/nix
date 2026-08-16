#!/bin/sh

# new-workspace.sh
# Moves every newly-opened tiling window to the lowest-numbered empty workspace.
#
# This is the sway counterpart of the hyprland one-liner in
# hypr.d/conf.d/windowrules.conf (`match:class .*, ..., workspace emptym`).
# Sway has no equivalent: `for_window [...] move container to workspace` only
# takes a STATIC target (`number N`, `next`, `prev`, `back_and_forth`), and
# `next` means the next workspace that already EXISTS -- it never creates one.
# Listening on IPC and moving each window as it appears is the only way.
#
# Why we want it: the launcher is beckon, which is focus-or-launch. The first
# Cap+b launches Brave -> new window -> this pushes it onto its own workspace.
# Every press after that focuses the existing window, so sway follows to that
# workspace by itself. Net effect: one app per workspace, navigated by app key
# rather than by workspace number -- which is why $mod+1..4 in shortcuts.conf
# is left as-is even though it becomes near-redundant.
#
# Started from conf.d/system.conf with `exec`, NOT `exec_always`: sway re-runs
# `exec_always` on every reload and Tab+r is a key we press often, so that would
# stack one daemon per reload and move each new window once per daemon. The cost
# is that turning this on needs a sway RESTART ($mod+Shift+r); a reload will not
# start it.
#
# Depends on swaymsg (sway) and jq (home-manager/pkgs/dev, enabled on rog).

swaymsg -t subscribe -m '["window"]' \
| jq --unbuffered -r 'select(.change == "new") | .container.id' \
| while read -r id; do
    [ -n "$id" ] || continue

    # Emits either "skip" or "<target-workspace> <current-workspace>".
    plan=$(swaymsg -t get_tree | jq -r --argjson id "$id" '
      # A real window (a "view") is the only node carrying .pid -- outputs,
      # workspaces and split containers do not have one.
      def views: [ .. | objects | select(has("pid")) | .id ];

      [ .. | objects | select(.type == "workspace") ] as $wss

      # Floating windows (dialogs, file pickers, popups) stay put.
      | [ $wss[] | .floating_nodes[]? | views[] ] as $floating

      # A workspace is busy if it holds a window OTHER than the new one.
      | [ $wss[] | select((views | map(select(. != $id)) | length) > 0) | .num ] as $busy

      # Where sway put the new window on its own.
      | ([ $wss[] | select(views | index($id)) | .num ] | first) as $cur

      | if ($floating | index($id)) != null or $cur == null then "skip"
        else
          [ first(range(1; 100) | . as $n | select(($busy | index($n)) == null)), $cur ]
          | map(tostring) | join(" ")
        end
    ')

    case "$plan" in
      skip | "") continue ;;
    esac

    target=${plan% *}
    cur=${plan#* }
    [ "$target" = "$cur" ] && continue

    # Two commands, not one chained pair: a `[con_id=...]` criteria at the head
    # of a chain applies to every command in it, and `workspace` is not a
    # container command.
    swaymsg "[con_id=$id] move container to workspace number $target" >/dev/null
    swaymsg "workspace number $target" >/dev/null
  done
