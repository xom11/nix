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


# herdr-mobile-relay
# Dieu khien agent herdr tu dien thoai. Tat la endpoint cong khai tra 530 ngay.
# Hostname CO Y khong ghi o day (repo public) — doc tu config cloudflared luc chay.
_relay_service="gui/$(id -u)/com.herdr-mobile-relay.service"
_relay_plist="$HOME/Library/LaunchAgents/com.herdr-mobile-relay.service.plist"

relay-on() {
    # enable PHAI truoc bootstrap: con trong danh sach disabled thi nap vao
    # cung khong chay, va launchctl khong bao loi ro rang.
    herdr plugin enable herdr-mobile-relay.events >/dev/null 2>&1
    launchctl enable "$_relay_service"
    launchctl bootstrap "gui/$(id -u)" "$_relay_plist" || return 1
    sleep 1
    relay-status
}

relay-off() {
    # bootout luc da tat san bao "3: No such process" — vo hai
    launchctl bootout "$_relay_service" 2>/dev/null
    launchctl disable "$_relay_service"
    herdr plugin disable herdr-mobile-relay.events >/dev/null 2>&1
    relay-status
}

relay-status() {
    # KHONG dung `pgrep -f herdr-mobile-relay`: chuoi do nam trong command line
    # cua chinh lenh dang chay nen luon khop -> duong tinh gia.
    if launchctl print "$_relay_service" 2>/dev/null | grep -q 'state = running'; then
        local host
        host=$(awk '/hostname:/ {print $3; exit}' \
            "$HOME/.config/herdr/plugins/config/herdr-mobile-relay.events/cloudflared/config.yml" 2>/dev/null)
        echo "relay ON   ${host:+https://$host}"
    else
        echo "relay OFF"
    fi

    # herdr KHONG co launchd agent -> sau reboot phai mo terminal mot lan.
    # relay chay ma herdr khong: app noi duoc nhung danh sach RONG.
    if pgrep -x herdr >/dev/null; then
        echo "herdr ON"
    else
        echo "herdr OFF  -- go 'herdr' trong terminal"
    fi
}
