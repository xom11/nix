```lua
-- Reverse scroll direction for trackpads
reverse_trackpad_scroll = hs.eventtap.new({hs.eventtap.event.types.scrollWheel}, function(event)
    -- detect if this is touchpad or mouse
    local isTrackpad = event:getProperty(hs.eventtap.event.properties.scrollWheelEventIsContinuous)
    if isTrackpad ~= 1 then
        return false -- mouse: pass the event along
    end
    -- vertical scroll in pixels
    event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis1))
    -- horizontal scroll in pixels
    event:setProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2,
        -event:getProperty(hs.eventtap.event.properties.scrollWheelEventPointDeltaAxis2))
    return false -- pass the event along 
end):start()
```