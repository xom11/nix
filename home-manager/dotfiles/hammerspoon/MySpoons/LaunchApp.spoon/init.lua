local obj = {}
obj.__index = obj

local hyper = { "cmd", "ctrl", "alt" }

local defaultShortcuts = {
	{ "b", "Vivaldi" },
  { "c", "Claude" },
	{ "d", "Discord" },
	{ "f", "Finder" },
	{ "g", "Google Gemini" },
	{ "k", "Google Keep" },
	{ "m", "Messenger" },
	{ "n", "Notion" },
	{ "s", "System Settings" },
	{ "space", "kitty" },
	{ "t", "Telegram" },
	-- { "v", "Visual Studio Code" },
	{ "y", "Youtube" },
	{ "z", "Zalo" },
}
local extendShortcuts = {
	{ "a", "Launchpad" },
  { "b", "Brave Browser" },
	{ "c", "Google Chrome" },
	{ "d", "DeepSeek - Into the Unknown" },
	{ "m", "Gmail" },
	{ "v", "VMware Fusion" },
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

local function launch(appName)
	-- Error when using window instead of application: pwa
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
		-- focusedApp:hide()
    -- ERROR: browser not using vimium/surfingkeys when hiding and focusing again
    -- FIX: Switch to another app window if possible, else hide
		local windows = hs.window.orderedWindows()
		local foundOtherApp = false

    -- BUG: windows[2] maybe not work
    -- FIX: loop through all windows
		for i = 2, #windows do
			local win = windows[i]
			local winApp = win:application()
			if winApp and winApp:bundleID() ~= focusedBundleID and win:isStandard() then
				win:focus()
				foundOtherApp = true
				break
			end
		end

		if not foundOtherApp then
      focusedApp:hide()
		end

	else
		hs.application.launchOrFocusByBundleID(targetBundleID)
		moveCursorToCenter()
	end
end

function obj:init()
	for _, shortcut in ipairs(defaultShortcuts) do
		hs.hotkey.bind(hyper, shortcut[1], function()
			launch(shortcut[2])
		end)
	end

	-- Build a keymap for extendShortcuts so that hyper + a + <key> launches the app
	local keymap = {}
	for _, shortcut in ipairs(extendShortcuts) do
		-- rb.singleKey will add 'shift' modifier automatically for uppercase letters
		keymap[rb.singleKey(shortcut[1], shortcut[2])] = function()
			launch(shortcut[2])
		end
	end

	local starter = rb.recursiveBind(keymap)
	hs.hotkey.bind(hyper, "a", starter)
end

return obj
