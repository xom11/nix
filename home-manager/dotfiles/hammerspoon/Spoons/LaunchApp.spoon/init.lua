local obj = {}
obj.__index = obj

local tab = {"cmd", "ctrl", "alt", "shift"}
local cap = {"cmd", "ctrl", "alt"}


local defaultShortcuts = {
    {cap, "space", "kitty"},
    {cap, "A", "Launchpad"},
    {cap, "B", "Brave Browser"},
    {cap, "D", "Discord"},
    {tab, "D", "DeepSeek - Into the Unknown"},
    {cap, "F", "Finder"},
    {cap, "K", "Google Keep"},
    {cap, "G", "Google Gemini"},
    {cap, "M", "Messenger"},
    {cap, "N", "Notion"},
    {cap, "T", "Telegram"},
    {cap, "S", "System Settings"},
    {tab, "M", "Gmail"},
    {cap, "V", "Visual Studio Code"},
    {cap, "Y", "Youtube"},
    {cap, "Z", "Zalo"},
}

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
        local modifiers = shortcut[1]
        local key = shortcut[2]
        local appName = shortcut[3]

        hs.hotkey.bind(modifiers, key, function()
            self:launch(appName)
        end)
    end
end

return obj
