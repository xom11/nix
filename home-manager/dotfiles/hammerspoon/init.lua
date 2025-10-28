hs = hs
-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
local Install=spoon.SpoonInstall

tab = {"cmd", "alt", "ctrl", "shift"}
cap = { "ctrl", "alt", "cmd" }
alt = {"alt"}

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

-- Draw on screen. ctrl-alt-cmd+c/a/t.  (c)lear/(a)nnotate/(t)oggle
local drawonscreen = require('drawonscreen')
local hotkey = hs.hotkey.modal.new(ultra, 'a')

function hotkey:entered()
  drawonscreen.start()
  drawonscreen.startAnnotating()
end

function hotkey:exited()
  drawonscreen.stopAnnotating()
  drawonscreen.hide()
end

hotkey:bind(ultra, 'c', function() drawonscreen.clear() end)
hotkey:bind(ultra, 'a', function() hotkey:exit() end)
hotkey:bind(ultra, 't', function() drawonscreen.toggleAnnotating() end)

-- Reload config with Cmd+Alt+Ctrl+Shift+R
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "R", function()
  hs.reload()
end)
hs.alert.show("Config loaded")

-- Reverse scroll direction for trackpads
reverse_trackpad_scroll = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    -- detect if this is touchpad or mouse
    local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
    if isTrackpad ~= 1 then
        return false -- mouse: pass the event along
    end
    
    -- Đảo chiều cuộn dọc (theo dòng)
    -- event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
    --     -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
        
    -- -- Đảo chiều cuộn ngang (theo dòng)
    -- event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2,
    --     -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2))

    -- Đảo chiều cuộn dọc (theo pixel) - QUAN TRỌNG
    event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1))

    -- Đảo chiều cuộn ngang (theo pixel) - QUAN TRỌNG
    event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2))
        
    return false -- pass the event along (gửi đi sự kiện đã bị sửa)
end):start()


