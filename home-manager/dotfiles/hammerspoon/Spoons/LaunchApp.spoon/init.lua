local obj = {}
obj.__index = obj

function obj.launch(appName)
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then
        hs.application.launchOrFocus(appName)
        return
    end   
    local focusedApp = focusedWindow:application()
    if not focusedApp then
        hs.application.launchOrFocus(appName)
        return
    end
    local focusedBundleID = focusedApp:bundleID()
    local _, targetBundleID = hs.osascript.applescript([[id of application "]] .. appName .. [["]])

    -- print("Focused Bundle ID: " .. tostring(focusedBundleID))
    -- print("Target Bundle ID: " .. tostring(targetBundleID))
    if focusedBundleID == targetBundleID then
        focusedApp:hide()
    else
        hs.application.launchOrFocusByBundleID(targetBundleID)
    end
end

return obj