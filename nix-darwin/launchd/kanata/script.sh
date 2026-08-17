CONFIG_PATH="$1"
COMMAND=(sudo /opt/homebrew/bin/kanata -c $CONFIG_PATH -n)
# LOG_FILE="/tmp/kanata_monitor.log"

# --- log rotation ------------------------------------------------------------
# The VirtualHIDDevice daemon prints `virtual_hid_keyboard_ready true` on a
# loop even when everything is healthy. Measured 2026-08-17: ~2.7 MB/day, and
# nothing on macOS rotates it -- kanata.out.log had reached 107 MB.
#
# TRUNCATE IN PLACE, never rename. launchd opens StandardOutPath itself and
# holds the fd, so a `mv`/`newsyslog`-style rotation leaves it writing to the
# renamed inode: the fresh file stays 0 bytes forever while the .1 keeps
# growing. Truncating keeps the inode, and launchd opens the file O_APPEND so
# writes resume at 0 rather than leaving a sparse hole -- verified by hand
# before this was written, by truncating the live 107 MB file and watching it
# grow again from 0.
#
# `cp` before truncating, so one generation survives for diagnosis. Cap is
# per-file, so the pair costs at most 2 x LOG_MAX.
LOG_MAX=$((5 * 1024 * 1024))
LOG_FILES="/Library/Logs/Kanata/kanata.out.log /Library/Logs/Kanata/kanata.err.log"

rotate_logs() {
    for f in $LOG_FILES; do
        size=$(stat -f%z "$f" 2>/dev/null) || continue
        [ "$size" -gt "$LOG_MAX" ] || continue
        cp "$f" "$f.1" 2>/dev/null && : > "$f"
    done
}

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
rotate_logs
start_daemon
LAST_STATE=$(get_input_devices_state)

# monitor input devices for changes
TICKS=0
while true; do
    CURRENT_STATE=$(get_input_devices_state)

    if [[ "$CURRENT_STATE" != "$LAST_STATE" ]]; then
        echo new "$CURRENT_STATE" old "$LAST_STATE"
        restart_daemon
        LAST_STATE="$CURRENT_STATE"
    fi

    # Every 60 ticks = ~2 min. At the measured 2.7 MB/day the cap cannot be
    # overshot by more than a few KB, so a tighter interval buys nothing and
    # a `stat` per 2 s costs more than it saves.
    TICKS=$((TICKS + 1))
    if [ "$TICKS" -ge 60 ]; then
        TICKS=0
        rotate_logs
    fi

    sleep 2
done