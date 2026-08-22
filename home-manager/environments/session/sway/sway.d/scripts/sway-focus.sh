#!/bin/sh

# sway-focus.sh
# Focuses or launches an application window in sway by its app_id.
#
# Usage:
#   sway-focus.sh <LAUNCH_CMD...>
#
# App ID is auto-detected:
#   - If --app=URL is present: match by domain (works across browsers)
#   - Otherwise: basename of the first argument (binary name)
#
# Behavior:
#   - If the currently focused window matches, switch to the previous window.
#   - If a matching window exists, move it to its workspace and focus it.
#   - If no such window exists, switch to the workspace and launch the application.

LAUNCH_CMD="$*"

# Auto-detect app_id pattern and default workspace name
APP_URL=$(echo "$LAUNCH_CMD" | grep -oP '(?<=--app=)https?://\S+')
if [ -n "$APP_URL" ]; then
  # Web app: use domain as regex to match any browser's web app id
  DEFAULT_WS=$(echo "$APP_URL" | sed 's|https\?://||; s|/$||; s|/.*||')
  PATTERN="$DEFAULT_WS"
else
  # Regular app: exact match on binary name
  DEFAULT_WS=$(basename "$1")
  PATTERN="^${DEFAULT_WS}$"
fi

FOCUSED=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // .window_properties.instance // empty')
MATCH=$(swaymsg -t get_tree | jq -r ".. | select(.app_id? // \"\" | test(\"$PATTERN\")) | .app_id" | head -1)
WS_NAME=${MATCH:-$DEFAULT_WS}

if echo "$FOCUSED" | grep -q "$PATTERN"; then
  swaymsg workspace back_and_forth
elif [ -n "$MATCH" ]; then
  swaymsg "[app_id=\"$MATCH\"] move to workspace $WS_NAME"
  swaymsg workspace "$WS_NAME"
  swaymsg "[app_id=\"$MATCH\"] focus"
else
  swaymsg workspace "$WS_NAME"
  exec $LAUNCH_CMD
fi
