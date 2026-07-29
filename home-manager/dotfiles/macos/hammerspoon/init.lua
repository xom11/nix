hs = hs
spoon = spoon
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" .. hs.configdir .. "/MySpoons/?.spoon/init.lua"
package.path = package.path .. ";" .. hs.configdir .. "/LibSpoons/?.spoon/init.lua"

tab = { "cmd", "ctrl", "shift" }
cap = { "ctrl", "alt", "cmd" }

-- Spoon bên thứ ba nằm trong ~/.hammerspoon/Spoons, do Nix đặt vào từ input
-- hammerspoon-spoons đã ghim rev trong flake.lock (xem default.nix cạnh file này).
--
-- Trước đây chỗ này chạy SpoonInstall: nó gọi updateRepo("default") tải index 1,2 MB bằng
-- hs.http.get — đồng bộ, chặn main thread — ở mọi lần khởi động và mọi lần tab+r reload, kể
-- cả khi spoon đã nằm sẵn trên đĩa. Tệ hơn: Spoons/ bị .gitignore che, nên trên máy clone
-- mới mà mạng hỏng thì RecursiveBinder không tải được, rb.singleKey thành nil, LaunchApp
-- chết ngay dòng dưới và MỌI hotkey sau đó không được bind. Ghim qua Nix cắt cả hai vấn đề:
-- không lời gọi mạng nào lúc khởi động, và spoon luôn có mặt sau lần build đầu.
hs.loadSpoon("RecursiveBinder")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")

hs.loadSpoon("LaunchApp")
-- hs.loadSpoon("LaunchTerminal")
hs.loadSpoon("PowerManager")
-- hs.loadSpoon("GoNhanh")
hs.loadSpoon("WindowManager")
hs.loadSpoon("Fn")
hs.loadSpoon("Tab")
-- hs.loadSpoon("LanguageSwitcher")
hs.loadSpoon("LanguageMemory")

hs.alert.show("Hammerspoon config loaded")


