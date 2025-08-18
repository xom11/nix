
# pidof kitty && swaymsg [app_id=^kitty$] focus || (swaymsg workspace "kitty" && kitty)

if pidof kitty; then
    # Nếu kitty đang chạy, chuyển trọng tâm (focus) đến cửa sổ đó
    swaymsg '[app_id="kitty"] focus'
else
    # Nếu kitty chưa chạy, mở một workspace mới có tên "kitty" và khởi động kitty
    swaymsg 'workspace "kitty"'
    kitty &
fi