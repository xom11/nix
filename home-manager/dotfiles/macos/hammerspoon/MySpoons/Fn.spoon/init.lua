--- === Fn ===
---
--- Điều khiển chuột bằng bàn phím khi giữ fn: h/j/k/l cuộn, `,` và `.` click trái/phải.
---
--- https://github.com/Hammerspoon/Spoons/tree/master/Source/FnMate.spoon

local obj = {}
obj.__index = obj

-- fn + phím -> lượng cuộn {ngang, dọc}
local SCROLL = {
    h = { 3, 0 },
    l = { -3, 0 },
    j = { 0, -3 },
    k = { 0, 3 },
}

-- fn + phím -> cặp sự kiện chuột (nhấn, nhả)
local CLICK = {
    [","] = { "leftMouseDown", "leftMouseUp" },
    ["."] = { "rightMouseDown", "rightMouseUp" },
}

-- Bản trước còn một biến thể biến fn+hjkl thành phím mũi tên thay vì cuộn:
--     return true, {hs.eventtap.event.newKeyEvent({}, "left", true)}
-- Giữ lại đây làm ghi chú; đổi SCROLL sang bảng phím mũi tên là dùng lại được.

function obj:init()
    local types = hs.eventtap.event.types

    local function catcher(event)
        -- Thoát sớm khi không giữ fn, và chỉ đọc cờ MỘT lần.
        --
        -- Bản cũ là chuỗi if/elseif gọi event:getFlags() và event:getCharacters() tới 6 lần
        -- cho MỖI phím gõ trên máy — kể cả khi không hề giữ fn, tức là gần như toàn bộ thời
        -- gian gõ phím bình thường.
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
            -- Trả cặp sự kiện cho hệ thống tự post, KHÔNG gọi hs.eventtap.leftClick().
            --
            -- leftClick(point) mặc định chèn timer.usleep(200000) giữa down và up
            -- (hs/eventtap.lua:160-168). 200 ms đó chạy ngay BÊN TRONG callback của eventtap
            -- keyDown, nên nó chặn đường đi của mọi phím khác suốt thời gian ấy — gõ phím bị
            -- đơ mỗi lần click. Nó cũng không return gì, nên `{hs.eventtap.leftClick(...)}`
            -- của bản cũ thực chất là một bảng rỗng: click xảy ra do tác dụng phụ, không phải
            -- do giá trị trả về.
            local pos = hs.mouse.absolutePosition() -- getAbsolutePosition đã deprecated
            return true, {
                hs.eventtap.event.newMouseEvent(types[click[1]], pos),
                hs.eventtap.event.newMouseEvent(types[click[2]], pos),
            }
        end

        return false
    end

    -- Giữ tham chiếu trên obj chứ không phải trong _G. eventtap không còn ai tham chiếu sẽ bị
    -- garbage-collect và lặng lẽ ngừng chạy, nên BẮT BUỘC phải neo ở đâu đó — nhưng obj (chính
    -- là spoon.Fn, sống suốt phiên) đủ rồi, không cần thêm một global nữa.
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
