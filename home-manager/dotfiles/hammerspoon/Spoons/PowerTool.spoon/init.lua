local obj = {}
obj.__index = obj

function obj:init()
    -- Lock screen
    hs.hotkey.bind({"cmd", "alt"}, "L", function()
    hs.caffeinate.lockScreen()
    end)
    -- Shutdown
    hs.hotkey.bind({"cmd", "alt", "shift"}, "S", function()
    local button, text = hs.dialog.blockAlert("Shutdown System", "Are you sure you want to shutdown the system?", "Shutdown", "Cancel")
    if button == "Cancel" then
        return
    end
    hs.caffeinate.shutdownSystem()
    end)
    -- Restart
    hs.hotkey.bind({"cmd", "alt", "shift"}, "R", function()
    local button, text = hs.dialog.blockAlert("Restart System", "Are you sure you want to restart the system?", "Restart", "Cancel")
    if button == "Cancel" then
        return
    end
    hs.caffeinate.restartSystem()
    end)
    -- Logout
    hs.hotkey.bind({"cmd", "alt", "shift"}, "L", function()
    hs.caffeinate.logOut()
    end)
    -- Sleep
    hs.hotkey.bind({"cmd", "alt"}, "S", function()
    hs.caffeinate.systemSleep()
    end)
end

return obj