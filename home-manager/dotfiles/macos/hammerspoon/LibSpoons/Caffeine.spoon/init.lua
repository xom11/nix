--- === Caffeine ===
---
--- Giữ màn hình không tự tắt, kèm một chấm ☕ ở góc trên bên phải để biết đang bật.
---
--- Tách từ Tab.spoon.
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

local SIZE, INSET = 30, 6

local canvas
local screenWatcher

-- Đặt chấm vào góc trên bên phải của màn hình chính.
--
-- Bản trong Tab.spoon tính toạ độ MỘT LẦN lúc load rồi dựng canvas ở đó. Cắm/rút màn hình
-- hoặc đổi độ phân giải sau đó là chấm nằm sai chỗ, thậm chí ra ngoài vùng nhìn thấy được.
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
    canvas:appendElements({
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = 9, yRadius = 9 },
        fillColor = { red = 1, green = 0.25, blue = 0.1, alpha = 0.95 },
    }, {
        type = "text",
        text = "☕",
        textSize = 20,
        textAlignment = "center",
        frame = { x = 0, y = 4, w = SIZE, h = SIZE },
    })
    reposition()
end

--- Caffeine:isOn()
--- Method
--- Hỏi thẳng hệ thống thay vì giữ một biến cờ riêng.
---
--- hs.reload() gỡ mọi sleep prevention (hs/caffeinate.lua ghi rõ), nên một biến cờ nhớ trạng
--- thái qua lần reload sẽ lệch với thực tế. Đọc từ nguồn thì không bao giờ lệch.
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
        reposition() -- màn hình có thể đã đổi kể từ lần hiện trước
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
    -- Giữ watcher trên obj: watcher không còn ai tham chiếu sẽ bị garbage-collect và ngừng chạy.
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
