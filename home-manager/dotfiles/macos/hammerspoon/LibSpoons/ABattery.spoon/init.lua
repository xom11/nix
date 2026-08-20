local obj = {}
obj.name = "ABattery"

-- Appearance, matching AClock
obj.textFont = "Impact"
obj.textSize = 135
obj.textColor = {hex="#2ECC71"} -- Màu xanh lá cho Pin
obj.width = 450
obj.height = 230
obj.showDuration = 4
obj.hotkey = 'escape'

-- local, not global: the old `function getframe(...)` landed straight in _G.
-- Adds mainRes.x/y rather than assuming the primary screen sits at the origin, which is
-- wrong when it is arranged to the right of another display.
local function getframe(width, height)
    local mainRes = hs.screen.primaryScreen():fullFrame()
    return {
        x = mainRes.x + (mainRes.w - width) / 2,
        y = mainRes.y + (mainRes.h - height) / 2,
        w = width,
        h = height,
    }
end

function obj:init()
    self.canvas = hs.canvas.new({x=0, y=0, w=0, h=0})
    self.canvas[1] = {
        type = "text",
        textFont = self.textFont,
        textSize = self.textSize,
        textColor = self.textColor,
        textAlignment = "center",
    }
    self.canvas:frame(getframe(self.width, self.height))
    return self
end

function obj:update_text()
    local batt = hs.battery.percentage()

    -- On a desktop with no battery, percentage() returns nan -- a number, NOT nil, so
    -- `if not batt` misses it, and string.format("%d", nan) throws under Lua 5.4. Must be
    -- caught before formatting; math.floor does not help.
    --
    -- show() calls update_text() BEFORE canvas:show(), so the throw meant the canvas never
    -- appeared and escape was never bound -- the hotkey was fully broken on macmini.
    if type(batt) ~= "number" or batt ~= batt then
        self.canvas[1].text = "AC 🔌"
        return
    end

    local icon = hs.battery.isCharging() and "⚡️" or "🔋"
    self.canvas[1].text = string.format("%d%% %s", math.floor(batt + 0.5), icon)
end

function obj:show()
    -- Recomputed on show: init() runs once at load, so coordinates saved there go stale
    -- when a display is plugged or the resolution changes.
    self.canvas:frame(getframe(self.width, self.height))
    self:update_text()
    self.canvas:show()
    if self.hotkey then
        self.cancel_hotkey = hs.hotkey.bind({}, self.hotkey, function() self:hide() end)
    end
    return self
end

function obj:hide()
    -- nil after delete: hide() can run twice (escape, then the timer), and the second
    -- would delete an already-destroyed hotkey.
    if self.cancel_hotkey then
        self.cancel_hotkey:delete()
        self.cancel_hotkey = nil
    end
    self.canvas:hide()
    if self.show_timer then self.show_timer:stop(); self.show_timer = nil end
end

function obj:toggleShow()
    if self.canvas:isShowing() then
        self:hide()
    else
        self:show()
        self.show_timer = hs.timer.doAfter(self.showDuration, function() self:hide() end)
    end
end

return obj
