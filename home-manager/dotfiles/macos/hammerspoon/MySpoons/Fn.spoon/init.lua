--- https://github.com/Hammerspoon/Spoons/tree/master/Source/FnMate.spoon

local obj={}
obj.__index = obj


function obj:init()
    local function catcher(event)
        -- if event:getFlags()['fn'] and event:getCharacters() == "h" then
        --     return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}
        -- elseif event:getFlags()['fn'] and event:getCharacters() == "l" then
        --     return true, {hs.eventtap.event.newKeyEvent({}, "right", true)}
        -- elseif event:getFlags()['fn'] and event:getCharacters() == "j" then
        --     return true, {hs.eventtap.event.newKeyEvent({}, "down", true)}
        -- elseif event:getFlags()['fn'] and event:getCharacters() == "k" then
        --     return true, {hs.eventtap.event.newKeyEvent({}, "up", true)}

        -- Mouse scroll h/j/k/l
        if event:getFlags()['fn'] and event:getCharacters() == "h" then
            return true, {hs.eventtap.event.newScrollEvent({3, 0}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "l" then
            return true, {hs.eventtap.event.newScrollEvent({-3, 0}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "j" then
            return true, {hs.eventtap.event.newScrollEvent({0, -3}, {}, "line")}
        elseif event:getFlags()['fn'] and event:getCharacters() == "k" then
            return true, {hs.eventtap.event.newScrollEvent({0, 3}, {}, "line")}

        -- Mouse click , and .
        elseif event:getFlags()['fn'] and event:getCharacters() == "," then
            local currentpos = hs.mouse.getAbsolutePosition()
            return true, {hs.eventtap.leftClick(currentpos)}
        elseif event:getFlags()['fn'] and event:getCharacters() == "." then
            local currentpos = hs.mouse.getAbsolutePosition()
            return true, {hs.eventtap.rightClick(currentpos)}
        end
    end
    -- Giữ tham chiếu trên obj chứ không phải trong _G. eventtap không còn ai tham chiếu sẽ bị
    -- garbage-collect và lặng lẽ ngừng chạy, nên BẮT BUỘC phải neo ở đâu đó — nhưng obj (chính
    -- là spoon.Fn, sống suốt phiên) đủ rồi, không cần thêm một global nữa.
    obj.tapper = hs.eventtap.new({hs.eventtap.event.types.keyDown}, catcher):start()
end

function obj:stop()
    if obj.tapper then
        obj.tapper:stop()
        obj.tapper = nil
    end
    return self
end

return obj
