-- Enable Hammerspoon CLI
hs.ipc.cliInstall()

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
    
    event:setProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1))
    return false -- pass the event along
end):start()

