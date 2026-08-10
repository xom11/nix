-- Enable Hammerspoon CLI (`hs -c "..."`)
--
-- cliInstall() chỉ tạo symlink khi cliStatus() trả về ĐÚNG BẰNG `false`. Khi cài dở dang —
-- ví dụ có /usr/local/bin/hs nhưng thiếu share/man/man1/hs.1 — cliStatus trả về chuỗi
-- "broken", mà "broken" là truthy nên nhánh tạo symlink không bao giờ chạy: cliInstall() trần
-- sẽ kẹt vĩnh viễn và in "cli installation problem: incomplete installation" ở mỗi lần load.
-- Máy này đang đúng trạng thái đó. Gỡ hẳn rồi cài lại là cách duy nhất thoát ra.
if hs.ipc.cliStatus(nil, true) ~= true then
    hs.ipc.cliUninstall()
    hs.ipc.cliInstall()
end

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" .. hs.configdir .. "/MySpoons/?.spoon/init.lua"
package.path = package.path .. ";" .. hs.configdir .. "/LibSpoons/?.spoon/init.lua"

-- Bỏ `hs = hs` và `spoon = spoon`: cả hai đều là no-op, Hammerspoon đã đặt sẵn hai global đó
-- trước khi nạp file này.
--
-- Bỏ luôn hai global `tab` và `cap`. `cap` không có file nào dùng; `tab` cũng vậy — Tab.spoon
-- tự khai báo `local tab` riêng ở dòng 4 của nó. Modifier thật do kanata sinh ra
-- (configs/kanata/kanata_macos.kbd): Tab giữ = cmd+ctrl+shift, Caps giữ = cmd+ctrl+alt.

-- Spoon bên thứ ba nằm trong ~/.hammerspoon/Spoons, do Nix đặt vào từ input
-- hammerspoon-spoons đã ghim rev trong flake.lock (xem default.nix cạnh file này).
--
-- Trước đây chỗ này chạy SpoonInstall: nó gọi updateRepo("default") tải index 1,2 MB bằng
-- hs.http.get — đồng bộ, chặn main thread — ở mọi lần khởi động và mọi lần tab+r reload, kể
-- cả khi spoon đã nằm sẵn trên đĩa. Tệ hơn: Spoons/ bị .gitignore che, nên trên máy clone
-- mới mà mạng hỏng thì RecursiveBinder không tải được: spoon nào gọi
-- hs.loadSpoon("RecursiveBinder") lúc load nhận về nil, và hotkey của chính spoon đó không
-- bind được (xem default.nix cạnh file này để biết spoon nào đang thật sự dùng — đổi theo
-- thời gian, đừng chép tên cụ thể vào đây). Ghim qua Nix cắt cả hai vấn đề: không lời gọi
-- mạng nào lúc khởi động, và spoon luôn có mặt sau lần build đầu.
hs.loadSpoon("RecursiveBinder")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")

-- Focus-or-launch: beckon serve (launchd com.xom11.beckon-serve),
-- du lieu configs/shortcuts/apps.macos.toml — sua la an ngay.
-- hs.loadSpoon("LaunchTerminal")
hs.loadSpoon("PowerManager")
hs.loadSpoon("WindowManager")
hs.loadSpoon("Fn")
hs.loadSpoon("Tab")

-- Chế độ gõ do `tongue` lo, gọi từ LangSwitch.spoon (phím tắt, nạp qua Tab.spoon) và
-- LanguageMemory.spoon (nhớ theo từng app). Hai spoon cũ ở đây đã bỏ hẳn: GoNhanh.spoon tự
-- open/killall GoNhanh — đúng việc tongue sinh ra để làm, và giành mất slot toàn cục
-- inputSourceChanged của LanguageMemory; LanguageSwitcher.spoon thì đã hỏng từ lâu (cần
-- InputSourceSwitch, spoon đã bị gỡ khỏi default.nix) và trùng chức năng LanguageMemory.
hs.loadSpoon("LanguageMemory")

-- Máy khoá thì im tiếng, đăng nhập lại thì trả nguyên trạng. Không có bindHotkeys: nó chỉ nghe
-- hs.caffeinate.watcher, mọi việc làm trong init().
hs.loadSpoon("LockMute")

hs.alert.show("Hammerspoon config loaded")


