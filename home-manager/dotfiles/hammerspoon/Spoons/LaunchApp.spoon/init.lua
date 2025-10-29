local obj = {}
obj.__index = obj

local hyper = {"cmd", "ctrl", "alt"}

local defaultShortcuts = {
    {"space", "kitty"},
    {"b", "Brave Browser"},
    {"d", "Discord"},
    {"f", "Finder"},
    {"k", "Google Keep"},
    {"g", "Google Gemini"},
    {"m", "Messenger"},
    {"n", "Notion"},
    {"t", "Telegram"},
    {"s", "System Settings"},
    {"v", "Visual Studio Code"},
    {"y", "Youtube"},
    {"z", "Zalo"},
}
local extendShortcuts = {
    {"a", "Launchpad"},
    {"d", "DeepSeek - Into the Unknown"},
    {"m", "Gmail"},
}

local rb = hs.loadSpoon("RecursiveBinder")

function obj:launch(appName)
    local focusedApp = hs.application.frontmostApplication()
    local _, focusedBundleID = hs.osascript.applescript([[id of app (path to frontmost application as text)]])
    local _, targetBundleID = hs.osascript.applescript([[id of app "]] .. appName .. [["]])

    if not targetBundleID then
        hs.alert.show("Application '" .. appName .. "' not found!")
        return
    end

    -- print("Focused Bundle ID: " .. tostring(focusedBundleID))
    -- print("Target Bundle ID: " .. tostring(targetBundleID))
    if focusedBundleID == targetBundleID then
        focusedApp:hide()
    else
        hs.application.launchOrFocusByBundleID(targetBundleID)
    end
end

function obj:init()
    local self = self
    
    for _, shortcut in ipairs(defaultShortcuts) do
        local modifiers = hyper
        local key = shortcut[1]
        local appName = shortcut[2]

        hs.hotkey.bind(modifiers, key, function()
            self:launch(appName)
        end)
    end

    -- Build a keymap for extendShortcuts so that hyper + a + <key> launches the app
    local keymap = {}
    for _, shortcut in ipairs(extendShortcuts) do
        local key = shortcut[1]
        local appName = shortcut[2]
        -- rb.singleKey will add 'shift' modifier automatically for uppercase letters
        keymap[ rb.singleKey(key, appName) ] = function()
            self:launch(appName)
        end
    end

    local starter = rb.recursiveBind(keymap)
    hs.hotkey.bind(hyper, 'a', starter)
end

return obj
