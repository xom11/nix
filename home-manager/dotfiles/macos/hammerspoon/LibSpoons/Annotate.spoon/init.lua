--- === Annotate ===
---
--- A drawing modal wrapped around DrawOnScreen.
---
--- `enter` opens it; inside, `clear` erases, `toggle` switches drawing on and off,
--- and `enter` again or Escape leaves. Split out of Tab.spoon.
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
--- mapping needs: enter (required), clear, toggle.
---
--- Unlike the other spoons, the modal is built FROM the entering chord, so
--- hs.spoons.bindHotkeysToSpec cannot be used -- modal.new takes mods/key directly.
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

    -- The entering chord also leaves.
    modal:bind(mapping.enter[1], mapping.enter[2], function()
        modal:exit()
    end)

    -- Escape leaves too. While the modal is open DrawOnScreen covers the screen with a
    -- canvas that swallows the mouse, so clicks reach no app -- with only one exit chord,
    -- forgetting it would leave you stuck with no working mouse to find a way out.
    --
    -- Deliberately no auto-exit timer: it would not reset on drawing activity, so a
    -- long presentation would lose the overlay mid-sentence.
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
