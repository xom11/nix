#!/usr/bin/env bash
# Usage: switch-session.sh <session_name> <default_path>
# If current session == target → switch to last session
# If target exists → switch to it
# If target doesn't exist → create it at default_path and switch

session="$1"
path="$2"

current=$(tmux display-message -p '#S')

if [ "$current" = "$session" ]; then
    tmux switch-client -l
elif tmux has-session -t "$session" 2>/dev/null; then
    tmux switch-client -t "$session"
else
    tmux new-session -d -s "$session" -c "$path"
    tmux switch-client -t "$session"
fi
