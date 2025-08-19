if pidof kitty; then
    focused_id=$(swaymsg -t get_tree | jq '.. | select(.focused? and .focused == true).app_id' | tr -d '"')
    echo "Focused app ID: $focused_id"
    if [ "$focused_id" == "kitty" ]; then
        echo "Kitty is already focused"
        # swaymsg '[app_id="kitty"] focus'
    else
        echo "Focusing Kitty"
        # swaymsg '[app_id="kitty"] focus'
    fi
else
    swaymsg 'workspace "kitty"'
    kitty &
fi