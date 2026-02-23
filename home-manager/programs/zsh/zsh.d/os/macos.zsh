# alias
alias copy='pbcopy'



# kanata
rk() {
    local plist="/Library/LaunchDaemons/org.nixos.kanata.plist"
    local log_file=$(grep -A 1 "StandardErrorPath" "$plist" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

    sudo launchctl unload "$plist"
    sudo launchctl load "$plist"
    
    if [ -n "$log_file" ]; then
        sleep 1
        echo "LOG FILE: $log_file"
        sudo tail -n 20 "$log_file"
        echo "------------------------------"
        echo "kanata path:"
        which kanata
    else
        echo "Warning: Could not find log file path in $plist. Please check the plist file for the correct log file location."
    fi
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
}


# Function to set macOS desktop wallpaper. 
wp() {
    if [ -z "$1" ]; then
        echo "Error: Please provide the image file path. (Example: wp ~/Desktop/image.jpg or wp ./image.jpg)"
        return 1
    fi

    local absolute_path=$(realpath "$1" 2>/dev/null)

    if [ -z "$absolute_path" ]; then
        echo "Error: Image file not found or path is invalid: $1"
        return 1
    fi

    /usr/bin/osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$absolute_path\""
    
    echo "✅ Successfully set wallpaper to: $absolute_path"
}
