local obj = {}
obj.__index = obj

local hyper = { "cmd", "ctrl", "alt" }
-- Chromium-based only (supports --app=)
local browser = "Vivaldi"

-- Native macOS apps: hyper + key
local nativeShortcuts = {
	{ "b", browser },
	{ "c", "Google Chrome" },
	{ "f", "Finder" },
	{ "s", "System Settings" },
	{ "space", "kitty" },
	{ "z", "Zalo" },
}

-- Web apps via browser --app=: hyper + key
-- { key, launchUrl, matchPattern }
-- matchPattern: substring of URL to detect existing window
local webShortcuts = {
	{ "c", "https://claude.ai/new",        "claude.ai"         },
	{ "d", "https://discord.com/app",       "discord.com"       },
	{ "g", "https://gemini.google.com",     "gemini.google.com" },
	{ "k", "https://keep.google.com",       "keep.google.com"   },
	{ "m", "https://www.messenger.com",     "messenger.com"     },
	{ "n", "https://www.notion.so/",        "notion.so"         },
	{ "t", "https://web.telegram.org",      "telegram.org"      },
	{ "y", "https://www.youtube.com",       "youtube.com"       },
}

-- hyper + a + key (native)
local extendNative = {
	{ "a", "Launchpad"     },
	{ "b", "Brave Browser" },
	{ "c", "Google Chrome" },
	{ "v", "VMware Fusion" },
}

-- hyper + a + key (web)
local extendWeb = {
	{ "d", "https://chat.deepseek.com/", "chat.deepseek.com" },
	{ "m", "https://mail.google.com/",   "mail.google.com"   },
}

local rb = hs.loadSpoon("RecursiveBinder")

local function moveCursorToCenter()
	local focusedApp = hs.application.frontmostApplication()
	if focusedApp then
		local focusedWindow = focusedApp:focusedWindow()
		if focusedWindow then
			local frame = focusedWindow:frame()
			hs.mouse.setAbsolutePosition({
				x = frame.x + frame.w / 2,
				y = frame.y + frame.h / 2,
			})
		end
	end
end

local function switchAway(excludeWin)
	local excludeApp = excludeWin:application()
	local excludeBundleID = excludeApp and excludeApp:bundleID()
	local windows = hs.window.orderedWindows()
	for i = 2, #windows do
		local w = windows[i]
		local wApp = w:application()
		if w:id() ~= excludeWin:id() and w:isStandard()
			and wApp and wApp:bundleID() ~= excludeBundleID then
			w:focus()
			return
		end
	end
	if excludeApp then excludeApp:hide() end
end

-- Find the first real (non-web-app) browser window via a single AppleScript call.
-- Must be defined before launchNative which calls it.
local function findMainBrowserWindow()
	local app = hs.application.get(browser)
	if not app then return nil end

	local conditions = {}
	for _, s in ipairs(webShortcuts) do
		table.insert(conditions, 'URL of active tab of window i contains "' .. s[3] .. '"')
	end
	for _, s in ipairs(extendWeb) do
		table.insert(conditions, 'URL of active tab of window i contains "' .. s[3] .. '"')
	end
	local isWebApp = table.concat(conditions, " or ")

	local ok, winTitle = hs.osascript.applescript([[
		tell application "]] .. browser .. [["
			repeat with i from 1 to count of windows
				if not (]] .. isWebApp .. [[) then return title of window i
			end repeat
			return ""
		end tell
	]])
	if not ok or not winTitle or winTitle == "" then return nil end

	for _, win in ipairs(app:allWindows()) do
		if win:title() == winTitle then return win end
	end
	return nil
end

local function launchNative(appName)
	local _, focusedBundleID = hs.osascript.applescript([[id of app (path to frontmost application as text)]])
	local _, targetBundleID  = hs.osascript.applescript([[id of app "]] .. appName .. [["]])

	if not targetBundleID then
		hs.alert.show("App not found: " .. appName)
		return
	end

	if focusedBundleID == targetBundleID then
		local focusedWin = hs.window.focusedWindow()
		-- When toggling the browser, try to find the real (non-web-app) browser window.
		-- This handles the case where focus is on a --app= web window sharing the same bundle ID.
		local mainWin = (appName == browser) and findMainBrowserWindow() or nil
		if mainWin and focusedWin and mainWin:id() ~= focusedWin:id() then
			mainWin:focus()
			moveCursorToCenter()
		elseif focusedWin then
			switchAway(focusedWin)
		end
	else
		hs.application.launchOrFocusByBundleID(targetBundleID)
		moveCursorToCenter()
	end
end

-- Find a browser window whose tab URL contains matchPattern via AppleScript.
-- Returns a Hammerspoon window object or nil.
local function findBrowserWindow(matchPattern)
	local app = hs.application.get(browser)
	if not app then return nil end

	local ok, winTitle = hs.osascript.applescript([[
		tell application "]] .. browser .. [["
			repeat with i from 1 to count of windows
				repeat with t in tabs of window i
					if URL of t contains "]] .. matchPattern .. [[" then
						return title of window i
					end if
				end repeat
			end repeat
			return ""
		end tell
	]])
	if not ok or not winTitle or winTitle == "" then return nil end

	for _, win in ipairs(app:allWindows()) do
		if win:title() == winTitle then return win end
	end
	return nil
end

local function launchWeb(url, matchPattern)
	local targetWin = findBrowserWindow(matchPattern)
	local focusedWin = hs.window.focusedWindow()

	if targetWin then
		if focusedWin and focusedWin:id() == targetWin:id() then
			switchAway(targetWin)
		else
			targetWin:focus()
			moveCursorToCenter()
		end
	else
		hs.task.new("/usr/bin/open", nil, { "-na", browser, "--args", "--app=" .. url }):start()
	end
end

function obj:init()
	for _, s in ipairs(nativeShortcuts) do
		hs.hotkey.bind(hyper, s[1], function() launchNative(s[2]) end)
	end

	for _, s in ipairs(webShortcuts) do
		hs.hotkey.bind(hyper, s[1], function() launchWeb(s[2], s[3]) end)
	end

	local keymap = {}

	for _, s in ipairs(extendNative) do
		keymap[rb.singleKey(s[1], s[2])] = function() launchNative(s[2]) end
	end

	for _, s in ipairs(extendWeb) do
		local label = s[3]:match("^([^/]+)")
		keymap[rb.singleKey(s[1], label)] = function() launchWeb(s[2], s[3]) end
	end

	local starter = rb.recursiveBind(keymap)
	hs.hotkey.bind(hyper, "a", starter)
end

return obj
