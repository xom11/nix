# beckon-serve

`beckon serve` chạy như launchd agent (`com.xom11.beckon-serve`), đọc
`configs/shortcuts/launch-app.toml` từ working tree — sửa file là áp dụng
trong ~1-2 s, không cần switch.

## Không cấp quyền gì cả (từ 10/08/2026)

Agent trỏ **thẳng vào nix store**. Không còn bản copy ở `~/.local/libexec`,
không còn khối `home.activation.beckonServeBinary`, không có mục `beckon`
nào trong Accessibility.

Lý do bỏ được: beckon chỉ đụng Accessibility ở đúng **hai** chỗ, cả hai đều
nằm sau nhánh "app đã đang được focus":

| Việc | Cần quyền? |
|---|---|
| Bắt phím tắt (`RegisterEventHotKey`, không thuộc TCC) | không |
| Mở app chưa chạy / focus app đang chạy (`open -b`) | không |
| Nhảy về app trước đó / ẩn app | không |
| Xoay cửa sổ trong cùng một app (bước 5a) | **có** |
| Đếm cửa sổ để dựng lại app đã minimize hết | **có** |

Không grant thì hai dòng cuối rơi mềm xuống "nhảy sang app khác" — không lỗi,
không cảnh báo. Không grant thì cũng chẳng cần path cố định để treo grant vào,
nên mẹo copy-ra-libexec biến mất theo.

Hệ quả kèm theo: store path nằm trong plist, nên mỗi lần bump beckon plist
đổi, home-manager so bằng `cmp -s` rồi `bootout` + `bootstrap` lại. Agent tự
chạy binary mới — không còn cần `launchctl kickstart -k`.

### Nếu muốn 5a trở lại

Cấp quyền cho **một path cố định** — store path đổi mỗi lần build nên grant
sẽ chết theo. Khôi phục khối activation cũ từ git history
(`git log -p -- home-manager/programs/beckon-serve/`) rồi thêm
`~/.local/libexec/beckon` vào Accessibility.

Cách khác, sạch hơn nhưng tốn tiền: beckon ký Developer ID ($99/năm) thì TCC
bám vào chữ ký chứ không bám path, lúc đó trỏ thẳng store cũng giữ được grant
(đây là cách Hammerspoon / GoNhanh / Look làm).

## Log & chẩn đoán

- Log: `~/Library/Logs/beckon/serve.log` (cả stdout lẫn stderr).
- Agent sống? `launchctl print gui/$(id -u)/com.xom11.beckon-serve | head`
- Config hỏng lúc đang chạy → beckon GIỮ bảng cũ + notification; hỏng từ lúc
  khởi động → agent thoát, launchd thử lại mỗi 60 s (xem log).
