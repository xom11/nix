--- === Fn ===
---
--- Mouse from the keyboard while fn is held: h/j/k/l scroll, `,` and `.` click.
---
--- https://github.com/Hammerspoon/Spoons/tree/master/Source/FnMate.spoon

local obj = {}
obj.__index = obj

-- fn + key -> scroll amount {horizontal, vertical}
local SCROLL = {
    h = { 3, 0 },
    l = { -3, 0 },
    j = { 0, -3 },
    k = { 0, 3 },
}

-- fn + key -> mouse event pair (down, up)
local CLICK = {
    [","] = { "leftMouseDown", "leftMouseUp" },
    ["."] = { "rightMouseDown", "rightMouseUp" },
}

-- An earlier variant made fn+hjkl arrow keys instead of scrolling:
--     return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}

function obj:init()
    local types = hs.eventtap.event.types

    local function catcher(event)
        -- Bail out early and read the flags ONCE: the previous if/elseif chain called
        -- getFlags() and getCharacters() up to six times for EVERY keystroke on the
        -- machine, fn held or not.
        if not event:getFlags()["fn"] then
            return false
        end

        local ch = event:getCharacters()

        local scroll = SCROLL[ch]
        if scroll then
            return true, { hs.eventtap.event.newScrollEvent(scroll, {}, "line") }
        end

        local click = CLICK[ch]
        if click then
            -- Return the event pair for the system to post; do NOT call leftClick(),
            -- which sleeps 200 ms between down and up INSIDE this keyDown callback and
            -- so stalls every other key for that long. It also returns nothing, so the
            -- old `{hs.eventtap.leftClick(...)}` was an empty table -- the click was a
            -- side effect, not the return value.
            local pos = hs.mouse.absolutePosition() -- getAbsolutePosition is deprecated
            return true, {
                hs.eventtap.event.newMouseEvent(types[click[1]], pos),
                hs.eventtap.event.newMouseEvent(types[click[2]], pos),
            }
        end

        return false
    end

    -- Anchored on obj, not _G: an unreferenced eventtap is collected and stops silently,
    -- and obj lives for the whole session, so no extra global is needed.
    obj.tapper = hs.eventtap.new({ types.keyDown }, catcher):start()
end

function obj:stop()
    if obj.tapper then
        obj.tapper:stop()
        obj.tapper = nil
    end
    return self
end

return obj
