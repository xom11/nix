local obj = {}
obj.name = "ABattery"

-- Cấu hình giao diện (giống hệt AClock của bạn)
obj.textFont = "Impact"
obj.textSize = 135
obj.textColor = {hex="#2ECC71"} -- Màu xanh lá cho Pin
obj.width = 450
obj.height = 230
obj.showDuration = 4
obj.hotkey = 'escape'

function getframe(width, height)
    local mainScreen = hs.screen.primaryScreen()
    local mainRes = mainScreen:fullFrame()
    return { x = (mainRes.w - width) / 2, y = (mainRes.h - height) / 2, w = width, h = height }
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
    local isCharging = hs.battery.isCharging()
    local icon = isCharging and "⚡️" or "🔋"
    self.canvas[1].text = string.format("%d%% %s", batt, icon)
end

function obj:show()
    self:update_text()
    self.canvas:show()
    if self.hotkey then
        self.cancel_hotkey = hs.hotkey.bind({}, self.hotkey, function() self:hide() end)
    end
    return self
end

function obj:hide()
    if self.cancel_hotkey then self.cancel_hotkey:delete() end
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
