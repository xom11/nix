--- === Caffeine ===
---
--- Giữ màn hình không tự tắt, kèm một chấm cam ở góc trên bên phải để biết đang bật.
---
--- Tách từ Tab.spoon.
---
--- Có bản đối ứng bên Windows ở `home-manager/dotfiles/windows/ahk/caffeine.ahk`,
--- cùng phím Tab+c và cùng cái chấm — nhưng **khác nghĩa**, và đừng gộp hai bên lại:
--- bản này giữ MÀN HÌNH sáng (`displayIdle`), bản Windows cố ý chỉ giữ MÁY thức và
--- để màn hình tắt, vì trên a14 hễ ngủ là Tailscale rụng. Lý do đầy đủ ở đầu file đó.
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
    -- Một chấm tròn trơn, không chữ. Trước đây là hộp bo góc đỏ kèm ☕; bỏ emoji đi
    -- vì hai lý do, và lý do thứ hai mới là lý do thật:
    --
    -- 1. chấm trơn đọc nhanh hơn ở cỡ này -- ở 16pt thì emoji chỉ còn là một vệt.
    -- 2. bản Windows KHÔNG vẽ được emoji: `Gui.AddText` của AHK vẽ bằng GDI, mà GDI
    --    không đọc bảng màu COLR/CBDT nên ☕ rơi về glyph đơn sắc, ra một vòng tròn
    --    đen tràn khỏi hộp. Giữ emoji ở đây thì hai máy trông khác hẳn nhau.
    --
    -- Toạ độ mặc định của phần tử `circle` là tâm 50%/50%, bán kính 50%, nên nó tự
    -- vừa khít canvas -- không cần khai báo center/radius.
    --
    -- Ghi thẳng red/green/blue thay vì `hex`: giá trị số thì không phụ thuộc vào việc
    -- hs.drawing.color có phân tích được chuỗi hay không. #ff8c1a.
    canvas:appendElements({
        type = "circle",
        action = "fill",
        fillColor = { red = 1.0, green = 0.549, blue = 0.102, alpha = 0.85 },
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
