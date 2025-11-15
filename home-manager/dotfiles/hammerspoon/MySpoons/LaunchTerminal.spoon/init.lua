local obj = {}
obj.__index = obj

local hyper = { "cmd", "ctrl", "alt" }
local terminal = "kitty"

local defaultShortcuts = {
  -- shortcut, title, command
	{ "r", "rog", "open -na 'kitty' --args --title 'rog' -- ssh rog" },
	{ "m", "macmini", "open -na 'kitty' --args --title 'macmini' -- ssh macmini" },

}

local rb = hs.loadSpoon("RecursiveBinder")

local function moveCursorToCenter()
	local focusedApp = hs.application.frontmostApplication()

	if focusedApp then
		local focusedWindow = focusedApp:focusedWindow()

		if focusedWindow then
			local frame = focusedWindow:frame()

			local centerX = frame.x + frame.w / 2
			local centerY = frame.y + frame.h / 2

			hs.mouse.setAbsolutePosition({ x = centerX, y = centerY })
		end
	end
end

local function launch(title, command)
	-- Error when using window instead of application: pwa
	local focusedID = hs.window.frontmostWindow():id()
	local windows = hs.window.allWindows()
	for _, win in ipairs(windows) do
		if win:application():name() == terminal and win:title() == title then
      print("Found window: " .. win:title())
			if win:id() == focusedID then
				hs.application.frontmostApplication():hide()
        -- hs.alert.show("Hiding " .. title)
        return
			else
				win:focus()
				moveCursorToCenter()
        -- hs.alert.show("Focusing " .. title)
        return
			end
		end
	end
	-- true to use user shell environment
	hs.execute(command,true)
  -- hs.alert.show("Launching " .. title)
  -- return
	--
end

function obj:init()
	-- Build a keymap for shortcuts so that hyper + x + <key> launches the app
	local keymap = {}
	for _, shortcut in ipairs(defaultShortcuts) do
		local key = shortcut[1]
		local title = shortcut[2]
		local command = shortcut[3]
		-- rb.singleKey will add 'shift' modifier automatically for uppercase letters
		keymap[rb.singleKey(key, title)] = function()
			launch(title, command)
		end
	end

	local starter = rb.recursiveBind(keymap)
	hs.hotkey.bind(hyper, "x", starter)
end

return obj
