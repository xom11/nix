--- === LanguageMemory ===
---
--- Remember and restore the input mode per application, like fcitx5 does.
---
--- Two sources: learned automatically when the user presses a language key, and
--- manual overrides from setup(), which win.
---
--- Stores tongue MODES ("vi"/"en"/"zh"), not source IDs -- see onUserSwitch.
---
--- Usage:
--- ```lua
--- hs.loadSpoon("LanguageMemory")
--- spoon.LanguageMemory:start()
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "LanguageMemory"
obj.version = "2.0"
obj.author = "kln"
obj.homepage = "https://github.com/kln/nix"
obj.license = "MIT"

local log = hs.logger.new("LanguageMemory", "debug")

local memory = {}
local overrides = {}
local memoryFile = hs.configdir .. "/LanguageMemory.json"

local langSwitch
local appWatcher
local wakeWatcher
local listening = false

local VALID_MODE = { vi = true, en = true, zh = true }

-- Older memories stored source IDs, under this repo's convention that ABC meant
-- Vietnamese (with GoNhanh running). Converted on read so the file heals itself.
local LEGACY_SOURCE = {
    ["com.apple.keylayout.ABC"] = "vi",
    ["com.apple.keylayout.UnicodeHexInput"] = "en",
    ["com.apple.inputmethod.SCIM.ITABC"] = "zh",
}

-- System pseudo-processes fire `activated` like real apps and would be learned,
-- which is meaningless. "loginwindow" had already been recorded before this list.
local BLACKLIST = {
    ["loginwindow"] = true,
    ["ScreenSaverEngine"] = true,
    ["Hammerspoon"] = true,
    ["Spotlight"] = true,
    ["SystemUIServer"] = true,
    ["Dock"] = true,
    ["universalaccessd"] = true,
    ["coreautha"] = true,
    ["SecurityAgent"] = true,
}

local function save()
    hs.json.write(memory, memoryFile, false, true)
end

local function load()
    local data = hs.json.read(memoryFile)
    if not data then
        memory = {}
        return false
    end
    memory = data

    -- One pass does both: drop pseudo-apps learned before BLACKLIST existed, and
    -- convert legacy source IDs. Assigning nil to an EXISTING key is legal during
    -- pairs (only adding keys is not), so deleting in place is safe.
    local changed = 0
    for name, value in pairs(memory) do
        if BLACKLIST[name] then
            memory[name] = nil
            changed = changed + 1
        elseif not VALID_MODE[value] then
            -- Unrecognised means drop it: forgetting beats restoring the wrong mode.
            memory[name] = LEGACY_SOURCE[value]
            changed = changed + 1
        end
    end
    if changed > 0 then
        save()
        log.i(string.format("Đã dọn/chuyển đổi %d mục trong bộ nhớ", changed))
    end
    return true
end

-- No "what mode is it in?" check first: that costs a subprocess and the answer can
-- be stale by the time we act, while `tongue <mode>` is already idempotent.
local function onAppFocus(appName)
    if not appName then return end
    if BLACKLIST[appName] then return end

    local mode = overrides[appName] or memory[appName]
    if not mode then return end

    langSwitch:apply(mode)
end

-- Learn from the user's own keypress, not from a macOS event. Required: with an
-- external IME, `vi` and `en` share one input source, so macOS fires no
-- inputSourceChanged for the most common switch -- an event-based version would see
-- only the Chinese one. It also removes the echo problem, since restores go through
-- :apply() and stay silent.
local function onUserSwitch(mode)
    local app = hs.application.frontmostApplication()
    if not app then return end
    local name = app:name()
    if not name then return end

    if BLACKLIST[name] then return end
    if overrides[name] then return end -- never overwrite a manual override
    if memory[name] == mode then return end

    memory[name] = mode
    save()
    log.d("Learned: " .. name .. " → " .. mode)
end

function obj:start()
    -- This file self-starts on load AND the docstring tells users to call :start(),
    -- so a second call would orphan the old watcher -- still running, no longer
    -- stoppable.
    self:stop()

    load()

    langSwitch = hs.loadSpoon("LangSwitch")

    -- Once per Lua session: LangSwitch listeners can be added but not removed, so a
    -- second start() would call us twice per switch. A reload resets this flag.
    if not listening then
        langSwitch:onModeChange(onUserSwitch)
        listening = true
    end

    -- Watch app focus
    appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.activated then
            onAppFocus(name)
        end
    end)
    appWatcher:start()

    -- `activated` alone is not enough: after wake or unlock the focused app does not
    -- re-fire it, leaving whatever mode loginwindow set. Delayed a beat to settle.
    wakeWatcher = hs.caffeinate.watcher.new(function(event)
        local w = hs.caffeinate.watcher
        if event == w.screensDidUnlock or event == w.systemDidWake then
            hs.timer.doAfter(0.5, function()
                local app = hs.application.frontmostApplication()
                if app and app:name() then
                    onAppFocus(app:name())
                end
            end)
        end
    end)
    wakeWatcher:start()

    log.i("Started")
    return self
end

function obj:stop()
    if appWatcher then
        appWatcher:stop()
        appWatcher = nil
    end
    if wakeWatcher then
        wakeWatcher:stop()
        wakeWatcher = nil
    end
    log.i("Stopped")
    return self
end

--- LanguageMemory:setup(config)
--- Method
--- config.applications: appName -> mode, taking priority over what was learned.
function obj:setup(config)
    if config then
        if config.applications then
            for name, mode in pairs(config.applications) do
                if VALID_MODE[mode] then
                    overrides[name] = mode
                    memory[name] = mode
                else
                    log.e(string.format("bỏ qua %s: chế độ không hợp lệ %q", name, tostring(mode)))
                end
            end
            save()
        end
        if config.memoryFile then
            memoryFile = config.memoryFile
            load()
        end
    end
    return self
end

function obj:forget(name)
    memory[name] = nil
    overrides[name] = nil
    save()
    return self
end

function obj:forgetAll()
    memory = {}
    overrides = {}
    save()
    return self
end

function obj:getMemory()
    return memory
end

-- Auto-start on load
pcall(function()
    obj:start()
end)

return obj
