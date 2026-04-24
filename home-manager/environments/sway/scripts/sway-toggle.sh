#!/bin/bash

# sway-toggle.sh
# Toggle window visibility: if focused, move to hidden workspace; otherwise bring back.

APP_ID=$1
LAUNCH_CMD=$2
HIDDEN_WS="hidden_storage"

# Find windows matching the app_id or instance
WINDOW_DATA=$(swaymsg -t get_tree | jq -r --arg id "$APP_ID" '
  .. | select(.app_id? == $id or (.window_properties? != null and .window_properties.instance == $id))
  | "\(.id) \(.focused)"')

if [ -z "$WINDOW_DATA" ]; then
    # Not running -> launch
    swaymsg "exec $LAUNCH_CMD"
else
    read -r W_ID W_FOCUSED <<< "$(echo "$WINDOW_DATA" | head -n 1)"

    if [ "$W_FOCUSED" == "true" ]; then
        # Focused -> hide
        swaymsg "move container to workspace $HIDDEN_WS"
    else
        # Hidden or unfocused -> bring back
        CURRENT_WS=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true) | .name')
        swaymsg "[con_id=\"$W_ID\"] move container to workspace \"$CURRENT_WS\", focus"
    fi
fi
