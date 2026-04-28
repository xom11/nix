#!/bin/sh

# sway-beckon.sh <WORKSPACE> <BECKON_ID...>
#
# Focus-or-launch with strict app-per-workspace, no flicker.
#
# Behavior:
#   - Already running: move window to WORKSPACE first, then switch (so the
#     workspace is never displayed empty mid-transition).
#   - Not running: switch to WORKSPACE, then beckon launches into it.
#   - Already focused: toggle back to previous workspace.
#
# Resolution is delegated to `beckon -r`, which prints `Runtime id:` (== sway
# app_id) and `Status:` (running / not running).

set -e

WS="$1"
shift
ID="$*"

RESOLVED=$(beckon -r "$ID" 2>/dev/null || true)
APP_ID=$(printf '%s\n' "$RESOLVED" | awk -F': +' '/Runtime id:/ {print $2; exit}')
STATUS=$(printf '%s\n' "$RESOLVED" | awk -F': +' '/Status:/ {print $2; exit}')

# Fallback: resolution failed — switch then let beckon try.
if [ -z "$APP_ID" ]; then
  swaymsg "workspace \"$WS\""
  exec beckon "$ID"
fi

FOCUSED=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // empty')

if [ "$FOCUSED" = "$APP_ID" ]; then
  swaymsg workspace back_and_forth
elif [ "${STATUS#running}" != "$STATUS" ]; then
  swaymsg "[app_id=\"$APP_ID\"] move to workspace \"$WS\", focus; workspace \"$WS\""
else
  swaymsg "workspace \"$WS\""
  exec beckon "$ID"
fi
