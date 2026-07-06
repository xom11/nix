# path
path+=(/opt/homebrew/opt/postgresql@18/bin)

# alias
alias copy='pbcopy'


# kanata
kr() {
    local plist="/Library/LaunchDaemons/org.nixos.kanata.plist"
    local log_file=$(grep -A 1 "StandardErrorPath" "$plist" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

    sudo launchctl unload "$plist"
    sudo launchctl load "$plist"

}
kra() {
  kr
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
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

}

ks() {
    local plist="/Library/LaunchDaemons/org.nixos.kanata.plist"
    sudo launchctl unload "$plist"
    echo "kanata stopped."
}

kss() {
    ks
    pkill -x GoNhanh
    pkill -x Hammerspoon
    echo "Stop all (kanata, gonhanh, hammerspoon)"
}

krr() {
    kr
    open -a "GoNhanh"
    open -a "Hammerspoon"
    echo "Start all (kanata, gonhanh, hammerspoon)"
}
