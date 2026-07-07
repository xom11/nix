--- === LanguageMemory ===
---
--- Tự động nhớ và khôi phục input source cho từng application (giống fcitx5).
--- Khi focus app X, tự động switch về input source đã dùng lần cuối cho app X.
---
--- 2 chế độ:
--- 1. Học tự động — quan sát khi user đổi input source, ghi nhớ app → sourceID
--- 2. Config thủ công — dùng setApplications(), ưu tiên hơn học tự động
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
obj.version = "1.0"
obj.author = "kln"
obj.homepage = "https://github.com/kln/nix"
obj.license = "MIT"

local log = hs.logger.new("LanguageMemory", "debug")

-- ──────────────────────────────────────────────
-- Lưu trữ: appName → sourceID
-- ──────────────────────────────────────────────

local memory = {}
local overrides = {}
local memoryFile = hs.configdir .. "/LanguageMemory.json"

local appWatcher

-- ──────────────────────────────────────────────
-- Helper: chuyển sourceID → setLayout/setMethod
-- ──────────────────────────────────────────────

-- Cache: danh sách layout name → sourceID
-- "Unicode Hex Input" → "com.apple.keylayout.UnicodeHexInput"
local layoutIDs = {}
local methodIDs = {}

-- Xây dựng cache 1 lần
local function buildCache()
    layoutIDs = {}
    methodIDs = {}

    local layouts = hs.keycodes.layouts(true)   -- sourceIDs
    for _, sid in ipairs(layouts) do
        layoutIDs[sid] = true
    end

    local methods = hs.keycodes.methods(true)   -- sourceIDs
    for _, sid in ipairs(methods) do
        methodIDs[sid] = true
    end
end

-- Check xem sourceID có phải layout hay method
local function isLayout(sourceID)
    return layoutIDs[sourceID] or false
end
local function isMethod(sourceID)
    return methodIDs[sourceID] or false
end

-- Set input source từ sourceID
local function setSource(sourceID)
    if isLayout(sourceID) then
        return hs.keycodes.currentSourceID(sourceID)
    elseif isMethod(sourceID) then
        return hs.keycodes.currentSourceID(sourceID)
    end
    return false
end

-- ──────────────────────────────────────────────
-- Persist
-- ──────────────────────────────────────────────

local function save()
    hs.json.write(memory, memoryFile, false, true)
end

local function load()
    local data = hs.json.read(memoryFile)
    if data then
        memory = data
        return true
    end
    memory = {}
    return false
end

-- ──────────────────────────────────────────────
-- Logic chính
-- ──────────────────────────────────────────────

-- Khi app A được focus: restore ngay lập tức
local function onAppFocus(appName)
    if not appName then return end

    local sid = overrides[appName] or memory[appName]
    if not sid then return end

    setSource(sid)
end

-- Khi user đổi input source: học ngay
local function onInputChange()
    local app = hs.application.frontmostApplication()
    if not app then return end
    local name = app:name()
    if not name then return end

    if overrides[name] then return end  -- không ghi đè config thủ công

    local sid = hs.keycodes.currentSourceID()
    if not sid then return end

    if memory[name] == sid then return end  -- không đổi

    memory[name] = sid
    save()
    log.d("Learned: " .. name .. " → " .. sid)
end

-- ──────────────────────────────────────────────
-- API
-- ──────────────────────────────────────────────

function obj:start()
    buildCache()
    load()

    -- Watch app focus
    appWatcher = hs.application.watcher.new(function(name, event, app)
        if event == hs.application.watcher.activated then
            onAppFocus(name)
        end
    end)
    appWatcher:start()

    -- Watch input source change → học
    hs.keycodes.inputSourceChanged(onInputChange)

    log.i("Started")
    return self
end

function obj:stop()
    if appWatcher then
        appWatcher:stop()
        appWatcher = nil
    end
    log.i("Stopped")
    return self
end

function obj:setup(config)
    if config then
        if config.applications then
            for name, sid in pairs(config.applications) do
                overrides[name] = sid
                memory[name] = sid
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