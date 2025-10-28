-- AppCycler.spoon/init.lua

local obj = {}
obj.__index = obj

-- Core function to cycle or launch/focus an application.
-- This function is now exposed for the user to bind manually.
--- AppCycler.launchOrFocusOrCycle(appNameOnDisk)
-- Tries to cycle to the next window of an app if it's already focused.
-- Otherwise, launches or focuses the app.
function obj.launchOrFocusOrCycle(appNameOnDisk)
    -- Get the currently focused window object
    local focusedWindow = hs.window.focusedWindow()
    if not focusedWindow then 
        hs.application.launchOrFocus(appNameOnDisk)
        return
    end

    -- Get the focused window's application details
    local focusedApp = focusedWindow:application()
    local focusedAppName = focusedApp:name()

    -- Extract the app name on disk from its path for comparison
    local focusedAppPath = focusedApp:path()
    local appNameOnDiskCleaned = focusedAppPath:match("/Applications/([^/]+).app") or focusedAppPath:match("/System/Library/CoreServices/([^/]+).app")
    
    if not appNameOnDiskCleaned then 
        appNameOnDiskCleaned = focusedAppName 
    end

    -- If the target app is already focused, cycle its windows
    if string.match(appNameOnDiskCleaned, appNameOnDisk) then
        local targetApp = hs.application.get(focusedAppName)
        if not targetApp then return end

        local appWindows = targetApp:allWindows()

        if #appWindows > 0 then
            -- Find the current window's position in the list
            local currentWindowIndex = nil
            for i, win in ipairs(appWindows) do
                if win:id() == focusedWindow:id() then
                    currentWindowIndex = i
                    break
                end
            end

            local nextIndex = (currentWindowIndex and currentWindowIndex % #appWindows) + 1
            
            -- Cycle logic (simplified/standard approach)
            if appNameOnDisk == "Finder" then
                -- Complex Finder logic for cycling only visible windows
                local visibleWindows = {}
                for _, win in ipairs(appWindows) do
                    if win:isMovable() then 
                        table.insert(visibleWindows, win)
                    end
                end

                if #visibleWindows > 0 then
                    local currentVisibleIndex = nil
                    for i, win in ipairs(visibleWindows) do
                        if win:id() == focusedWindow:id() then
                            currentVisibleIndex = i
                            break
                        end
                    end
                    local nextVisibleIndex = (currentVisibleIndex and currentVisibleIndex % #visibleWindows) + 1
                    visibleWindows[nextVisibleIndex]:focus()
                end
            else
                -- Cycle to the next window in the list
                appWindows[nextIndex]:focus()
            end
        else
            targetApp:activate()
        end
    else
        -- Launch/focus the target app
        hs.application.launchOrFocus(appNameOnDisk)
    end
end

-- We don't need 'init', 'start', or 'stop' methods anymore, 
-- just the core function and return the object.
return obj