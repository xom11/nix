#!/bin/sh

INSTANCE=$1
LAUNCH_CMD=$2

# 1. Kiểm tra xem cửa sổ có đang tồn tại không
WINDOW_EXISTS=$(i3-msg -t get_tree | jq -r ".. | select(.window_properties? != null and .window_properties.instance == \"$INSTANCE\") | .id" | head -n 1)

if [ -z "$WINDOW_EXISTS" ]; then
    # TRƯỜNG HỢP 1: Chưa chạy -> Chạy mới
    # Chạy ứng dụng và đợi một chút để nó kịp khởi tạo, sau đó đưa vào scratchpad và hiển thị
    i3-msg "exec $LAUNCH_CMD"
    # Lưu ý: Một số app nặng cần sleep 1-2s mới nhận diện được class/instance để move
    sleep 0.5
    i3-msg "[instance=\"^$INSTANCE$\"] move scratchpad; [instance=\"^$INSTANCE$\"] scratchpad show"
else
    # Kiểm tra xem cửa sổ đó có đang được focus hay không
    IS_FOCUSED=$(i3-msg -t get_tree | jq -r ".. | select(.focused? == true and .window_properties.instance == \"$INSTANCE\") | .id")

    if [ -n "$IS_FOCUSED" ]; then
        # TRƯỜNG HỢP 2: Đang focus -> Ẩn nó đi (đưa vào scratchpad)
        i3-msg "move scratchpad"
    else
        # TRƯỜNG HỢP 3: Đã chạy nhưng chưa focus (đang ẩn hoặc ở ws khác) -> Gọi nó ra ws hiện tại
        i3-msg "[instance=\"^$INSTANCE$\"] scratchpad show"
    fi
fi
