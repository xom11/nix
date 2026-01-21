#!/bin/sh

INSTANCE=$1
LAUNCH_CMD=$2
USE_NEW_WS=${3:-true}

FOCUSED_INSTANCE=$(i3-msg -t get_tree | jq -r '.. | select(.focused? == true).window_properties.instance')

if [ "$FOCUSED_INSTANCE" = "$INSTANCE" ]; then
  # i3-back
  i3-msg [con_mark=_back] focus
else
  if ! i3-msg "[instance=\"^$INSTANCE$\"] focus" >/dev/null 2>&1; then
    if [ "$USE_NEW_WS" = "true" ]; then
      i3-msg workspace "$INSTANCE"
    fi
    exec $LAUNCH_CMD
  fi
fi
