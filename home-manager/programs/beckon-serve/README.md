# beckon-serve

`beckon serve` chạy như launchd agent (`com.xom11.beckon-serve`), đọc
`configs/shortcuts/apps.macos.toml` từ working tree — sửa file là áp dụng
trong ~1-2 s, không cần switch.

## Cấp quyền Accessibility (MỘT lần, sau lần switch đầu)

Hotkey chạy được KHÔNG cần quyền gì. Riêng bước cycle-giữa-các-cửa-sổ (5a)
cần Accessibility, và agent tự chịu TCC (không còn "ké" Hammerspoon):

1. Switch xong, xác nhận binary tồn tại: `ls ~/.local/libexec/beckon`
2. System Settings → Privacy & Security → Accessibility → `+` →
   nhấn Cmd+Shift+G, gõ `~/.local/libexec/beckon` → Open → bật toggle.
3. Kiểm: `~/.local/libexec/beckon doctor` phải in "Accessibility permission granted".

Grant sống qua các lần copy đè cùng path (tiền lệ kanata Homebrew). Nếu một
ngày cycle 5a ngừng chạy sau khi bump beckon: vào lại danh sách, gỡ rồi thêm
lại đúng path đó.

## Log & chẩn đoán

- Log: `~/Library/Logs/beckon/serve.log` (cả stdout lẫn stderr).
- Agent sống? `launchctl print gui/$(id -u)/com.xom11.beckon-serve | head`
- Config hỏng lúc đang chạy → beckon GIỮ bảng cũ + notification; hỏng từ lúc
  khởi động → agent thoát, launchd thử lại mỗi 60 s (xem log).
