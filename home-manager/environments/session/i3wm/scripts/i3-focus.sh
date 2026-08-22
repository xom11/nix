#!/bin/sh

# i3-focus.sh
# Focuses or launches an application window in i3wm by its window instance name.
#
# Usage:
#   i3-focus.sh <INSTANCE> <LAUNCH_CMD>
#
# Arguments:
#   INSTANCE   - The window instance name to focus or launch.
#   LAUNCH_CMD - The command to launch the application if not running.
#
# Behavior:
#   - If the currently focused window matches INSTANCE, switch to the previous window.
#   - If a window with INSTANCE exists, move it to its workspace and focus it.
#   - If no such window exists, switch to the workspace and launch the application.

INSTANCE=$1
LAUNCH_CMD=$2
FOCUSED_INSTANCE=$(i3-msg -t get_tree | jq -r '.. | select(.focused? == true).window_properties.instance')

if [ "$FOCUSED_INSTANCE" = "$INSTANCE" ]; then
  i3-msg [con_mark=_back] focus
else
  if i3-msg "[instance=\"^$INSTANCE$\"] focus" >/dev/null 2>&1; then
    # Move the window to its workspace and focus it
    i3-msg "[instance=\"^$INSTANCE$\"] move to workspace $INSTANCE"
    i3-msg workspace "$INSTANCE"
    i3-msg "[instance=\"^$INSTANCE$\"] focus"
  else
    i3-msg workspace "$INSTANCE"
    exec $LAUNCH_CMD
  fi
fi
