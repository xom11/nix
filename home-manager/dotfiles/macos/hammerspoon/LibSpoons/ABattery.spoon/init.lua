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

-- local, không phải global: bản cũ khai báo `function getframe(...)` nên nó nằm thẳng
-- trong _G cùng với mọi thứ khác của Hammerspoon.
--
-- Cộng thêm mainRes.x/y thay vì giả định màn hình chính nằm ở gốc toạ độ — không đúng khi
-- màn hình chính được đặt bên phải một màn hình khác trong Displays.
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

    -- Máy để bàn không có pin thì hs.battery.percentage() trả về nan — là number, KHÔNG phải
    -- nil, nên `if not batt` không bắt được. string.format("%d", nan) ném "number has no
    -- integer representation" dưới Lua 5.4, và math.floor(nan + 0.5) vẫn là nan nên cũng
    -- không cứu được: phải chặn trước khi format.
    --
    -- Vì show() gọi update_text() TRƯỚC canvas:show(), lỗi này làm canvas không bao giờ hiện
    -- và escape không kịp bind — tab+p hỏng hoàn toàn trên macmini, mỗi lần bấm là một cửa sổ
    -- lỗi đỏ. (Kiểm trên máy: percentage()=nan, isCharging()=nil, powerSource()="AC Power".)
    if type(batt) ~= "number" or batt ~= batt then
        self.canvas[1].text = "AC 🔌"
        return
    end

    local icon = hs.battery.isCharging() and "⚡️" or "🔋"
    self.canvas[1].text = string.format("%d%% %s", math.floor(batt + 0.5), icon)
end

function obj:show()
    -- Tính lại khung mỗi lần hiện: init() chỉ chạy một lần lúc load, nên nếu cắm/rút màn hình
    -- hay đổi độ phân giải sau đó thì toạ độ lưu từ init đã lệch.
    self.canvas:frame(getframe(self.width, self.height))
    self:update_text()
    self.canvas:show()
    if self.hotkey then
        self.cancel_hotkey = hs.hotkey.bind({}, self.hotkey, function() self:hide() end)
    end
    return self
end

function obj:hide()
    -- Gán nil sau khi delete: hide() có thể được gọi hai lần (bấm escape rồi show_timer bắn),
    -- lần thứ hai sẽ delete lại một hotkey đã bị huỷ.
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
