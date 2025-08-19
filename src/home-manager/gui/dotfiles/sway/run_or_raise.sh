command=$1
app_id=$2

if pidof "$app_id" >/dev/null; then

    focused_id=$(swaymsg -t get_tree | jq -r '.. | select(.focused? and .focused == true).app_id')
    if [ "$focused_id" == "$app_id" ]; then
        swaymsg workspace back_and_forth
    else
        swaymsg "[app_id=\"$app_id\"] focus"
    fi
else
    swaymsg "workspace \"$app_id\""
    exec "$command"
fi