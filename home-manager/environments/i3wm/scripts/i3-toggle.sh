#!/bin/bash

INSTANCE=$1
LAUNCH_CMD=$2
HIDDEN_WS="hidden_storage"

# 1. Lấy danh sách tất cả các cửa sổ có instance khớp với tham số
# Lọc lấy ID và trạng thái focus của cửa sổ đó
WINDOW_DATA=$(i3-msg -t get_tree | jq -r --arg inst "$INSTANCE" '
  .. | select(.window_properties? != null and .window_properties.instance == $inst) 
  | "\(.id) \(.focused)"')

# Nếu không tìm thấy dữ liệu (WINDOW_DATA trống)
if [ -z "$WINDOW_DATA" ]; then
    # TRƯỜNG HỢP 1: Chưa chạy -> Chạy mới tại WS hiện tại
    i3-msg "exec $LAUNCH_CMD"
else
    # Tách ID và trạng thái Focused (true/false)
    # Lấy cửa sổ đầu tiên tìm thấy
    read -r W_ID W_FOCUSED <<< "$(echo "$WINDOW_DATA" | head -n 1)"

    if [ "$W_FOCUSED" == "true" ]; then
        # TRƯỜNG HỢP 2: Đang focus -> Đẩy sang workspace ẩn
        i3-msg "move container to workspace $HIDDEN_WS"
    else
        # TRƯỜNG HỢP 3: Đã chạy nhưng chưa focus (ở ẩn hoặc ws khác) -> Kéo về
        CURRENT_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true) | .name')
        i3-msg "[con_id=\"$W_ID\"] move container to workspace \"$CURRENT_WS\", focus"
    fi
fi
