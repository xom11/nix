#!/bin/sh

# sway-focus.sh
# Focuses or launches an application window in sway by its app_id.
#
# Usage:
#   sway-focus.sh <APP_ID> <LAUNCH_CMD>
#
# Behavior:
#   - If the currently focused window matches APP_ID, switch to the previous window.
#   - If a window with APP_ID exists, move it to its workspace and focus it.
#   - If no such window exists, switch to the workspace and launch the application.

APP_ID=$1
LAUNCH_CMD=$2
FOCUSED=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // .window_properties.instance // empty')

if [ "$FOCUSED" = "$APP_ID" ]; then
  swaymsg workspace back_and_forth
else
  if swaymsg "[app_id=\"^${APP_ID}$\"] focus" 2>/dev/null; then
    swaymsg "[app_id=\"^${APP_ID}$\"] move to workspace ${APP_ID}"
    swaymsg workspace "${APP_ID}"
    swaymsg "[app_id=\"^${APP_ID}$\"] focus"
  elif swaymsg "[instance=\"^${APP_ID}$\"] focus" 2>/dev/null; then
    swaymsg "[instance=\"^${APP_ID}$\"] move to workspace ${APP_ID}"
    swaymsg workspace "${APP_ID}"
    swaymsg "[instance=\"^${APP_ID}$\"] focus"
  else
    swaymsg workspace "${APP_ID}"
    exec $LAUNCH_CMD
  fi
fi
