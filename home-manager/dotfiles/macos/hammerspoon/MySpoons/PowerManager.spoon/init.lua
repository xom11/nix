--- === PowerManager ===
---
--- Lock / sleep / shutdown / restart / log out.
---
---   cmd+alt+L        lock screen
---   cmd+alt+S        sleep
---   cmd+alt+shift+S  shutdown  (confirms)
---   cmd+alt+shift+R  restart   (confirms)
---   cmd+alt+shift+L  log out

local obj = {}
obj.__index = obj

local DIALOG_W, DIALOG_H = 400, 200

-- Confirm WITHOUT blocking Lua. hs.dialog.blockAlert "will halt Lua code processing until
-- the alert is closed", which freezes every hotkey (including the reload key), both
-- eventtaps and the app watcher. If the dialog opens behind a fullscreen window, Hammerspoon
-- is stuck until someone finds it.
local function confirm(title, text, okLabel, action)
	-- Positioned at call time: the primary screen may have changed since load.
	local f = hs.screen.primaryScreen():frame()
	hs.dialog.alert(
		f.x + (f.w - DIALOG_W) / 2,
		f.y + (f.h - DIALOG_H) / 2,
		function(button)
			if button == okLabel then
				action()
			end
		end,
		title,
		text,
		okLabel,
		"Cancel",
		"critical"
	)
end

function obj:init()
	hs.hotkey.bind({ "cmd", "alt" }, "l", function()
		hs.caffeinate.lockScreen()
	end)

	hs.hotkey.bind({ "cmd", "alt" }, "s", function()
		hs.caffeinate.systemSleep()
	end)

	hs.hotkey.bind({ "cmd", "alt", "shift" }, "s", function()
		confirm("Shutdown System", "Are you sure you want to shutdown the system?", "Shutdown", function()
			hs.caffeinate.shutdownSystem()
		end)
	end)

	hs.hotkey.bind({ "cmd", "alt", "shift" }, "r", function()
		confirm("Restart System", "Are you sure you want to restart the system?", "Restart", function()
			hs.caffeinate.restartSystem()
		end)
	end)

	-- Deliberately unconfirmed, even though it is one shift away from lock: macOS still lets
	-- each app veto a logout, so a slip does not cost data.
	hs.hotkey.bind({ "cmd", "alt", "shift" }, "l", function()
		hs.caffeinate.logOut()
	end)
end

return obj
