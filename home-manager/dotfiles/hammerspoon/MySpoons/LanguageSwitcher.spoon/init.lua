local obj = {}
obj.__index = obj
-- NOTE:
-- Fcitx5 -> cn -> Gonhanh turn off -> en
-- ABC -> en -> Gonhanh turn on -> vn

-- local en = "Fcitx5"
local en = "Unicode Hex Input"
local vn = "ABC"

-- Browser used for --app= web apps (same as LaunchApp.spoon)
local browser = "Vivaldi"

-- Per-URL input source rules for browser web app windows.
-- InputSourceSwitch can only switch per app-name, not per window,
-- so we handle browser windows separately via hs.window.filter.
local browserWindowRules = {
	["claude.ai"]         = vn,
	["discord.com"]       = vn,
	["gemini.google.com"] = vn,
	["keep.google.com"]   = vn,
	["messenger.com"]     = vn,
	["notion.so"]         = vn,
	["telegram.org"]      = vn,
	["youtube.com"]       = vn,
	["chat.deepseek.com"] = vn,
	["mail.google.com"]   = vn,
	-- no match = real browser window, falls back to browser default below
}
local browserDefault = vn

spoon.SpoonInstall:andUse("InputSourceSwitch")

function obj:init()
	hs.loadSpoon("InputSourceSwitch")

	spoon.InputSourceSwitch:setApplications({
		["Alacritty"]    = en,
		["Brave Browser"] = en,
		-- Vivaldi excluded: handled entirely by browserFilter below
		-- to avoid race condition where InputSourceSwitch overrides windowFocused
		["Finder"]       = en,
		["Firefox"]      = vn,
		["Google Chrome"] = vn,
		["System Settings"] = en,
		["Visual Studio Code"] = en,
		["Zalo"]         = vn,
		["iTerm2"]       = en,
		["kitty"]        = en,
	})

	spoon.InputSourceSwitch:start()

	-- Per-window input source switching inside the browser.
	-- Needed because all --app= web apps share the same bundle ID as the browser.
	local browserFilter = hs.window.filter.new(browser)
	browserFilter:subscribe(hs.window.filter.windowFocused, function(win)
		local title = win:title():gsub('"', '\\"')
		local ok, url = hs.osascript.applescript(
			'tell application "' .. browser .. '"\n' ..
			'  repeat with w in windows\n' ..
			'    if name of w is "' .. title .. '" then return URL of active tab of w\n' ..
			'  end repeat\n' ..
			'  return ""\n' ..
			'end tell'
		)
		if not ok or not url or url == "" then return end

		for pattern, source in pairs(browserWindowRules) do
			if url:find(pattern, 1, true) then
				hs.keycodes.setLayout(source)
				return
			end
		end
		hs.keycodes.setLayout(browserDefault)
	end)
end

return obj
