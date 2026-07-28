hs = hs
spoon = spoon
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

-- Look for Spoons in ~/.hammerspoon/MySpoons as well
package.path = package.path .. ";" .. hs.configdir .. "/MySpoons/?.spoon/init.lua"
package.path = package.path .. ";" .. hs.configdir .. "/LibSpoons/?.spoon/init.lua"

tab = { "cmd", "ctrl", "shift" }
cap = { "ctrl", "alt", "cmd" }

hs.loadSpoon("SpoonInstall")

-- KHÔNG gọi spoon.SpoonInstall:updateRepo("default") ở đây. Nó tải index 1,2 MB của repo
-- Spoons bằng hs.http.get — đồng bộ, chặn main thread — ở MỌI lần Hammerspoon khởi động và
-- mọi lần tab+r reload, kể cả khi cả 4 spoon đã nằm sẵn trên đĩa. Docstring của chính
-- SpoonInstall cũng khuyên đừng dùng nó trong file config, và ghi rõ dữ liệu repo không được
-- lưu lại nên lần nào cũng tải lại từ đầu.
--
-- Bỏ đi là an toàn: andUse() gọi hs.spoons.use(name, arg, true) trước tiên, thấy spoon có sẵn
-- là trả về ngay không đụng mạng; chỉ khi thiếu spoon nó mới tự gọi updateRepo (init.lua:405-445
-- của SpoonInstall). Đo trên macmini: mất ~0,30 s mỗi lần load khi mạng tốt, và chặn tới hết
-- timeout của NSURLSession khi không có mạng — đúng lúc mở airm3 ở nơi chưa nối wifi.
--
-- use_syncinstall phải giữ = true: nếu để async thì spoon chưa sẵn sàng lúc LaunchApp load ở
-- dưới, rb.singleKey sẽ là nil và cả file chết từ đó.
spoon.SpoonInstall.use_syncinstall = true

spoon.SpoonInstall:andUse("RecursiveBinder")
spoon.SpoonInstall:andUse("AllBrightness")

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


