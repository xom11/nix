--- === Annotate ===
---
--- Lớp modal vẽ lên màn hình, bọc quanh DrawOnScreen.
---
--- Vào modal bằng phím `enter`; trong modal: `clear` xoá nét, `toggle` bật/tắt chế độ vẽ,
--- `enter` lần nữa hoặc Escape để thoát.
---
--- Tách từ Tab.spoon.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("Annotate"):bindHotkeys({
---     enter  = { tab, "d" },
---     clear  = { tab, "c" },
---     toggle = { tab, "t" },
--- })
--- ```

local obj = {}
obj.__index = obj

obj.name = "Annotate"
obj.version = "1.0"
obj.author = "kln"
obj.license = "MIT"

local draw
local modal

--- Annotate:bindHotkeys(mapping)
--- Method
--- mapping cần các khoá: enter (bắt buộc), clear, toggle.
---
--- Khác các spoon khác ở chỗ modal phải được tạo TỪ tổ hợp phím vào, nên không dùng
--- hs.spoons.bindHotkeysToSpec được — hs.hotkey.modal.new nhận thẳng mods/key.
function obj:bindHotkeys(mapping)
    if not mapping or not mapping.enter then
        hs.alert.show("Annotate: thiếu mapping.enter", 3)
        return self
    end

    draw = hs.loadSpoon("DrawOnScreen")
    modal = hs.hotkey.modal.new(mapping.enter[1], mapping.enter[2])
    obj.modal = modal

    function modal:entered()
        draw.start()
        draw.startAnnotating()
    end

    function modal:exited()
        draw.stopAnnotating()
        draw.hide()
    end

    if mapping.clear then
        modal:bind(mapping.clear[1], mapping.clear[2], function()
            draw.clear()
        end)
    end
    if mapping.toggle then
        modal:bind(mapping.toggle[1], mapping.toggle[2], function()
            draw.toggleAnnotating()
        end)
    end

    -- Chính tổ hợp vào cũng là tổ hợp ra.
    modal:bind(mapping.enter[1], mapping.enter[2], function()
        modal:exit()
    end)

    -- Escape cũng thoát. Trong lúc modal mở, DrawOnScreen phủ một canvas nuốt chuột
    -- (canvasMouseEvents + mouseCallback rỗng ở DrawOnScreen.spoon:48-49, cộng một eventtap
    -- bắt leftMouseDown/Dragged), nên click không tới được app nào. Nếu lối ra duy nhất là
    -- đúng một tổ hợp thì quên tổ hợp là kẹt, mà chuột đã hết tác dụng để mò ra.
    --
    -- Cố ý KHÔNG thêm timer tự thoát: nó không reset theo hoạt động vẽ, nên đang trình bày
    -- quá thời gian là overlay biến mất giữa chừng không báo trước.
    modal:bind({}, "escape", function()
        modal:exit()
    end)

    return self
end

function obj:stop()
    if modal then
        modal:exit()
    end
    return self
end

return obj
