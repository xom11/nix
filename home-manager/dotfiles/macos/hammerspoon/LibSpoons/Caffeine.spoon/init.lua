--- === Caffeine ===
---
--- Keep the display awake, with an orange dot top-right while it is on.
--- Split out of Tab.spoon.
---
--- The Windows counterpart (ahk/caffeine.ahk) shares the key and the dot but means something
--- DIFFERENT -- do not merge them. This keeps the SCREEN on; that one deliberately keeps only
--- the MACHINE awake, because on a14 sleeping drops Tailscale.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("Caffeine"):bindHotkeys({ toggle = { tab, "c" } })
--- ```

local obj = {}
obj.__index = obj

obj.name = "Caffeine"
obj.version = "1.0"
obj.author = "kln"
obj.license = "MIT"

local SIZE, INSET = 16, 8

local canvas
local screenWatcher

-- Recomputed rather than fixed at load, as Tab.spoon's version was: plugging a display or
-- changing resolution left the dot misplaced, sometimes off screen.
local function reposition()
    if not canvas then
        return
    end
    local screen = hs.screen.primaryScreen()
    if not screen then
        return
    end
    local f = screen:frame()
    canvas:frame({ x = f.x + f.w - SIZE - INSET, y = f.y + INSET, w = SIZE, h = SIZE })
end

local function build()
    canvas = hs.canvas.new({ x = 0, y = 0, w = SIZE, h = SIZE })
    canvas:level("overlay"):behaviorAsLabels({ "canJoinAllSpaces", "stationary" })
    -- A plain dot, no glyph. Partly because an emoji is a smudge at 16pt, but mainly
    -- because the Windows side CANNOT draw one -- GDI ignores the COLR/CBDT colour tables
    -- and falls back to a monochrome glyph -- and the two machines should match.
    --
    -- A `circle` defaults to centre 50%/50% radius 50%, so it fits the canvas on its own.
    -- Numeric colour rather than `hex` (#ff8c1a), which does not depend on string parsing.
    canvas:appendElements({
        type = "circle",
        action = "fill",
        fillColor = { red = 1.0, green = 0.549, blue = 0.102, alpha = 0.85 },
    })
    reposition()
end

--- Caffeine:isOn()
--- Method
--- Ask the system rather than keeping a flag: hs.reload() drops all sleep prevention, so a
--- flag that survives the reload would disagree with reality.
function obj:isOn()
    return hs.caffeinate.get("displayIdle") and true or false
end

--- Caffeine:set(on)
--- Method
function obj:set(on)
    hs.caffeinate.set("displayIdle", on)
    if not canvas then
        build()
    end
    if on then
        reposition() -- the display may have changed since the last show
        canvas:show()
    else
        canvas:hide()
    end
    return self
end

--- Caffeine:toggle()
--- Method
function obj:toggle()
    return obj:set(not obj:isOn())
end

function obj:init()
    build()
    -- Keep the watcher on obj: an unreferenced watcher is collected and stops silently.
    screenWatcher = hs.screen.watcher.new(reposition)
    screenWatcher:start()
    obj.screenWatcher = screenWatcher
    return self
end

function obj:stop()
    if screenWatcher then
        screenWatcher:stop()
        screenWatcher = nil
        obj.screenWatcher = nil
    end
    if canvas then
        canvas:hide()
    end
    return self
end

function obj:bindHotkeys(mapping)
    hs.spoons.bindHotkeysToSpec({
        toggle = function()
            obj:toggle()
        end,
    }, mapping)
    return self
end

return obj
