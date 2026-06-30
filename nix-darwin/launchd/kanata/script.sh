CONFIG_PATH="$1"
COMMAND=(sudo /opt/homebrew/bin/kanata -c $CONFIG_PATH -n)
# LOG_FILE="/tmp/kanata_monitor.log"

# get a list of input devices (vendor and product IDs)
get_input_devices_state() {
    ioreg -c IOHIDDevice -r | grep -E '"VendorID"|"ProductID"' | grep -v "5824" | grep -v "10203" | md5
}

# start the daemon and save its ID
start_daemon() {
    echo "$(date): Starting daemon: ${COMMAND[*]}"
    "${COMMAND[@]}" &
    DAEMON_PID=$!
}

# restart the daemon
restart_daemon() {
    echo "$(date): Input devices changed. Restarting daemon..."
    kill "$DAEMON_PID"
    wait "$DAEMON_PID" 2>/dev/null
    start_daemon
}

# start the daemon initially
start_daemon
LAST_STATE=$(get_input_devices_state)

# monitor input devices for changes
while true; do
    CURRENT_STATE=$(get_input_devices_state)

    if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
        echo new "$CURRENT_STATE" old "$LAST_STATE"
        restart_daemon
        LAST_STATE="$CURRENT_STATE"
    fi

    sleep 2
done