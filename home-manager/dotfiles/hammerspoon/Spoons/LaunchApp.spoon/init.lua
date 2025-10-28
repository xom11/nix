local obj = {}
obj.__index = obj

function obj.launch(appName)
    local focusedApp = hs.application.frontmostApplication()
    local _, focusedBundleID = hs.osascript.applescript([[id of app (path to frontmost application as text)]])
    local _, targetBundleID = hs.osascript.applescript([[id of app "]] .. appName .. [["]])

    print("Focused Bundle ID: " .. tostring(focusedBundleID))
    print("Target Bundle ID: " .. tostring(targetBundleID))
    if focusedBundleID == targetBundleID then
        focusedApp:hide()
    else
        hs.application.launchOrFocusByBundleID(targetBundleID)
    end
end

return obj
