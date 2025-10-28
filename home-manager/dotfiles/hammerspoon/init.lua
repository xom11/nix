hs = hs
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
local Install=spoon.SpoonInstall

tab = {"cmd", "alt", "ctrl", "shift"}
cap = { "ctrl", "alt", "cmd" }

Install:updateRepo('default')

-- -- Emojis selector. alt-e
-- Install:installSpoonFromRepo('Emojis')
-- local emojis = hs.loadSpoon('Emojis')
-- emojis.chooser:rows(15)
-- emojis:bindHotkeys({toggle={alt, 'e'}})

-- -- Hotkey cheatsheet.  alt-p
-- Install:installSpoonFromRepo('KSheet')
-- local sheet = hs.loadSpoon('KSheet')
-- sheet:bindHotkeys({toggle={alt, 'p'}})

-- Draw on screen (c)lear/(a)nnotate/(t)oggle
local drawonscreen = hs.loadSpoon("DrawOnScreen")
local hotkey = hs.hotkey.modal.new(tab, 'a')

function hotkey:entered()
  drawonscreen.start()
  drawonscreen.startAnnotating()
end

function hotkey:exited()
  drawonscreen.stopAnnotating()
  drawonscreen.hide()
end

hotkey:bind(tab, 'c', function() drawonscreen.clear() end)
hotkey:bind(tab, 'a', function() hotkey:exit() end)
hotkey:bind(tab, 't', function() drawonscreen.toggleAnnotating() end)

-- Reload config 
hs.hotkey.bind(tab, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- Reverse scroll direction for trackpads
hs.loadSpoon("TrackpadReverse")
if spoon.TrackpadReverse then
  spoon.TrackpadReverse:start()
end

-- Launch App shortcuts
hs.loadSpoon("LaunchApp")

-- 2. Định nghĩa danh sách phím tắt và ứng dụng
local ctrlCmdShortcuts = {
    {"C", "Calendar"},
    {"M", "Mail"},
    {"T", "iTerm"}, -- Ví dụ thêm ứng dụng tùy chỉnh
}

-- 3. Gán phím tắt bằng hàm từ Spoon
if spoon.LaunchApp and spoon.LaunchApp.launchOrFocusOrCycle then
    -- Lưu tham chiếu ngắn gọn đến hàm để gọi dễ hơn
    local cycleFunc = spoon.LaunchApp.launchOrFocusOrCycle
    
    for _, shortcut in ipairs(ctrlCmdShortcuts) do
        local key = shortcut[1]
        local appName = shortcut[2]
        
        hs.hotkey.bind({"ctrl","cmd"}, key, function()
            -- Gọi hàm lõi từ Spoon và truyền tên ứng dụng vào
            cycleFunc(appName)
        end)
    end
end