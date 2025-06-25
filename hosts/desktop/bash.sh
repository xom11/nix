#!/bin/bash

# Thư mục gốc nguồn (source)
SOURCE_DIR="$HOME/.nix-profile"
# Thư mục đích (destination)
DEST_DIR="$HOME/.local"

# Kiểm tra xem thư mục nguồn có tồn tại không
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Lỗi: Thư mục nguồn '$SOURCE_DIR' không tồn tại. Hãy đảm bảo Nix đã được cài đặt và ~/.nix-profile đã được tạo."
    exit 1
fi

echo "Bắt đầu tạo symlink từ '$SOURCE_DIR' sang '$DEST_DIR'..."

# Sử dụng find để duyệt qua tất cả các file và thư mục trong SOURCE_DIR
# -depth: Duyệt sâu vào các thư mục con trước
# -print0: In tên file kết thúc bằng null, an toàn hơn với tên file có khoảng trắng
find "$SOURCE_DIR" -depth -print0 | while IFS= read -r -d $'\0' item; do
    # Lấy đường dẫn tương đối của item từ SOURCE_DIR
    relative_path="${item#$SOURCE_DIR/}"

    # Tạo đường dẫn đích đầy đủ
    dest_path="$DEST_DIR/$relative_path"

    # Nếu item là một thư mục
    if [ -d "$item" ]; then
        # Tạo thư mục đích nếu nó chưa tồn tại
        if [ ! -d "$dest_path" ]; then
            echo "Tạo thư mục: $dest_path"
            mkdir -p "$dest_path"
        fi
    # Nếu item là một file hoặc symlink
    elif [ -f "$item" ] || [ -L "$item" ]; then
        # Tạo thư mục cha cho dest_path nếu nó chưa tồn tại
        mkdir -p "$(dirname "$dest_path")"

        # Kiểm tra nếu dest_path đã tồn tại và là symlink trỏ đúng chỗ
        if [ -L "$dest_path" ]; then
            current_target=$(readlink "$dest_path")
            if [ "$current_target" = "$item" ]; then
                echo "Đã tồn tại symlink chính xác: $dest_path -> $item (Bỏ qua)"
                continue
            else
                echo "Xóa symlink cũ sai: $dest_path -> $current_target"
                rm "$dest_path"
            fi
        # Nếu dest_path tồn tại nhưng không phải symlink hoặc symlink sai
        elif [ -e "$dest_path" ]; then
            echo "Cảnh báo: '$dest_path' đã tồn tại và không phải là symlink hoặc symlink không đúng. Đang xóa..."
            rm -rf "$dest_path" # Xóa để tạo lại symlink mới
        fi

        # Tạo symlink mới
        echo "Tạo symlink: $dest_path -> $item"
        ln -s "$item" "$dest_path"
    fi
done

echo "Hoàn tất quá trình tạo symlink."