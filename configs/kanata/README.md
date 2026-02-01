# BUG:
- trên window sẽ không thể giữ cap rồi bấm các phím khác liên tục được (k bị bug này trên macos, linux)
- ví dụ khi giữ cap + bấm gggg thì trả ra cap + g ở lần đầu sau đó là ggggg thay vì cap + g
- FIX: tạo layer cho phím cap rồi gán cho tất cả các nút khác
# CODE:
- luôn tạo alias, var rồi import main sau đó mới code thêm vì kanata sẽ đọc các layer từ trên xuống



