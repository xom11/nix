#!/bin/bash

# Danh sách URL ngăn cách bởi khoảng trắng
URLS=(
    "https://github.com"
)

for url in "${URLS[@]}"; do
    echo "Đang cài đặt: $url"
    osascript <<EOT
        tell application "Brave Browser"
            activate
            open location "$url"
            delay 4
        end tell
        tell application "System Events"
            tell process "Brave Browser"
                -- Thao tác click menu (Đảm bảo tên menu đúng với ngôn ngữ máy bạn)
                click menu item "Create Shortcut..." of menu 1 of menu item "More Tools" of menu 1 of menu bar item "File" of menu bar 1
                delay 1
                keystroke return
            end tell
        end tell
EOT
    sleep 2
done

echo "Hoàn thành cài đặt các Web App!"
