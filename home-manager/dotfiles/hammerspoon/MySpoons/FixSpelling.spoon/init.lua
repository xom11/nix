-- FixSpelling.spoon
-- Cmd+Ctrl+Shift+W  — toggle input (content preserved while hidden)
-- Input box: like Spotlight, auto focus, show current word if any, support left/right to move cursor, support backspace/delete to edit
-- Enter             — submit
-- Esc               — cancel
-- Output box: show result, auto copy to clipboard, press any key to dismiss

local obj = {}
obj.__index = obj

-- ── State ──────────────────────────────────────────────────────────────────
local inputChooser = nil
local resultCanvas = nil
local resultTap    = nil
local savedQuery   = ""
local modal        = hs.hotkey.modal.new()

-- ── Fix grammar/spelling via `aichat -r grammar` (stdin, login shell) ────
local function checkSpelling(text, callback)
    local task = hs.task.new("/bin/zsh", function(exitCode, out, err)
        local result = (out or ""):match("^%s*(.-)%s*$")
        if exitCode ~= 0 or result == "" then
            hs.alert.show("aichat error (exit " .. exitCode .. "):\n" .. (err ~= "" and err or "no output"))
            callback(text)
            return
        end
        callback(result)
    end, { "-lc", "aichat -r grammar" })
    task:setInput(text)
    task:start()
end

-- ── Result overlay ─────────────────────────────────────────────────────────
local function dismissResult()
    if resultTap    then resultTap:stop();      resultTap    = nil end
    if resultCanvas then resultCanvas:delete(); resultCanvas = nil end
end

local function showResult(original, corrected)
    dismissResult()

    hs.pasteboard.setContents(corrected)

    local isCorrect = (corrected == original)

    local sf    = hs.screen.mainScreen():frame()
    local pad   = 20
    local W     = math.min(800, sf.w - 80)
    local textW = W - pad * 2

    local sections = {}
    if isCorrect then
        table.insert(sections, {
            label      = "✓  Looks correct",
            body       = corrected,
            labelColor = { red = 0.4, green = 0.9, blue = 0.5, alpha = 1 },
        })
    else
        table.insert(sections, {
            label      = "Original",
            body       = original,
            labelColor = { red = 0.6, green = 0.6, blue = 0.6, alpha = 1 },
        })
        table.insert(sections, {
            label      = "Fixed  →",
            body       = corrected,
            labelColor = { red = 0.4, green = 0.75, blue = 1.0, alpha = 1 },
        })
    end
    table.insert(sections, {
        body = "Copied to clipboard · press any key to dismiss",
        hint = true,
    })

    local fontSize   = 17
    local hintSize   = 13
    local labelSize  = 12
    local labelH     = labelSize + 8
    local sectionGap = 14
    local charsPerLine = math.floor(textW / (fontSize * 0.6))
    local elements   = {}
    local yOff       = pad

    for _, sec in ipairs(sections) do
        local bodySize  = sec.hint and hintSize or fontSize
        local bodyLineH = bodySize + 6

        if sec.label then
            table.insert(elements, {
                type          = "text",
                text          = sec.label,
                textFont      = "Menlo",
                textSize      = labelSize,
                textColor     = sec.labelColor,
                textAlignment = "left",
                frame         = { x = pad, y = yOff, w = textW, h = labelH },
            })
            yOff = yOff + labelH + 4
        end

        local lines = math.max(1, math.ceil(#sec.body / charsPerLine))
        local bodyH = bodyLineH * lines + bodyLineH
        table.insert(elements, {
            type          = "text",
            text          = sec.body,
            textFont      = "Menlo",
            textSize      = bodySize,
            textColor     = sec.hint
                            and { red = 0.5, green = 0.5, blue = 0.5, alpha = 1 }
                            or  { red = 1.0, green = 1.0, blue = 1.0, alpha = 1 },
            textAlignment = "left",
            frame         = { x = pad, y = yOff, w = textW, h = bodyH },
        })
        yOff = yOff + bodyH + sectionGap
    end

    local H = yOff + pad - sectionGap
    local x = sf.x + (sf.w - W) / 2
    local y = sf.y + sf.h * 0.35

    resultCanvas = hs.canvas.new({ x = x, y = y, w = W, h = H })
    resultCanvas:appendElements({
        type             = "rectangle",
        action           = "fill",
        roundedRectRadii = { xRadius = 12, yRadius = 12 },
        fillColor        = { red = 0.08, green = 0.08, blue = 0.08, alpha = 0.96 },
        strokeColor      = { red = 0.35, green = 0.35, blue = 0.35, alpha = 0.6  },
        frame            = { x = 0, y = 0, w = W, h = H },
    })
    for _, el in ipairs(elements) do
        resultCanvas:appendElements(el)
    end

    resultCanvas:show()
    resultCanvas:bringToFront(true)

    resultTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function()
        dismissResult()
        return false
    end)
    resultTap:start()
end

-- ── Get selected text from the active app via clipboard ───────────────────
local function getSelectedText()
    local prev = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({ "cmd" }, "c")
    hs.timer.usleep(100000)
    local sel = (hs.pasteboard.getContents() or ""):match("^%s*(.-)%s*$")
    if prev then hs.pasteboard.setContents(prev) end
    return sel
end

-- ── Input chooser ──────────────────────────────────────────────────────────
local function buildChooser()
    local c = hs.chooser.new(function(_) end)  -- submission handled by modal
    c:width(50)
    c:rows(0)
    c:searchSubText(false)
    c:bgDark(true)
    c:fgColor({ red = 1, green = 1, blue = 1, alpha = 1 })
    c:placeholderText("Enter text to rewrite…")
    c:choices(function() return {} end)
    return c
end

-- ── Modal: Enter = submit, Esc = cancel ────────────────────────────────────
local function hideInput()
    modal:exit()
    if inputChooser then inputChooser:hide() end
end

modal:bind("", "return", function()
    local text = inputChooser and (inputChooser:query() or ""):match("^%s*(.-)%s*$") or ""
    hideInput()
    savedQuery = ""
    if text == "" then return end
    local loadingId = hs.alert.show("⏳ Waiting for aichat…", 999)
    checkSpelling(text, function(corrected)
        hs.alert.closeSpecific(loadingId)
        showResult(text, corrected)
    end)
end)

modal:bind("", "escape", function()
    savedQuery = ""
    hideInput()
end)

-- ── Toggle show / hide ─────────────────────────────────────────────────────
local function toggle()
    if inputChooser and inputChooser:isVisible() then
        savedQuery = inputChooser:query() or ""
        hideInput()
        return
    end

    if not inputChooser then inputChooser = buildChooser() end

    local restoring = savedQuery ~= ""
    if restoring then
        inputChooser:query(savedQuery)
        savedQuery = ""
    else
        inputChooser:query(getSelectedText())
    end

    inputChooser:show()
    modal:enter()
end

-- ── Spoon entry point ──────────────────────────────────────────────────────
function obj:init()
    hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "W", toggle)
end

return obj
