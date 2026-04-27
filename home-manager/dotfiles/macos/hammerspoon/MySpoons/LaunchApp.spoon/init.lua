--- LaunchApp.spoon — beckon-backed focus-or-launch.
---
--- The previous version (`init.lua.backup`) implemented the
--- focus / hide / toggle-back logic in pure Lua via osascript +
--- hs.application.launchOrFocusByBundleID + hs.window.orderedWindows.
---
--- This version delegates the whole algorithm to `beckon` (Rust CLI). The
--- spoon's only job now is binding hotkeys and calling out to beckon with
--- the user-friendly Name. beckon resolves the Name against
--- LaunchServices, and runs the full focus / launch / cycle / toggle / hide
--- algorithm — including step 5a (cycle within an app's windows) which the
--- old Lua version skipped.
---
--- See https://github.com/xom11/beckon

local obj = {}
obj.__index = obj

local hyper = { "cmd", "ctrl", "alt" }

local defaultShortcuts = {
	{ "b", "Vivaldi" },
	{ "c", "Claude" },
	{ "d", "Discord" },
	{ "f", "Finder" },
	{ "h", "Gemini" },
	{ "g", "Google Gemini" },
	{ "k", "Google Keep" },
	{ "m", "Messenger" },
	{ "n", "Notion" },
	{ "s", "System Settings" },
	{ "space", "kitty" },
	{ "t", "Telegram" },
	{ "o", "Obsidian" },
	{ "y", "Youtube" },
	{ "z", "Zalo" },
	{ "q", "Qutebrowser" },
	{ "j", "Tao Monitor" },
}
local extendShortcuts = {
	{ "a", "Launchpad" },
	{ "b", "Brave Browser" },
	{ "c", "Google Chrome" },
	{ "d", "DeepSeek - Into the Unknown" },
	{ "m", "Gmail" },
	{ "v", "VMware Fusion" },
	{ "f", "Firefox" },
}

local rb = hs.loadSpoon("RecursiveBinder")

-- Path to the beckon binary. We DON'T use `hs.execute(cmd, true)` because
-- the second arg sources the user's login shell (~/.zshrc) before each
-- invocation — on a typical machine that's 200–1000 ms, on this user's
-- setup it exceeds 10 s. Calling beckon directly from a known absolute
-- path bypasses shell startup entirely.
--
-- /etc/profiles/per-user/<user>/bin is where home-manager's useUserPackages
-- places the symlinks for `home.packages`, so this resolves the same binary
-- that `which beckon` would resolve from a normal terminal session.
local function beckonPath()
	local user = os.getenv("USER") or "kln"
	return "/etc/profiles/per-user/" .. user .. "/bin/beckon"
end

-- Fire and forget via hs.task — non-blocking. beckon exits in ~20 ms but
-- macOS focus changes are async anyway, so there's nothing useful to wait
-- for. We attach a callback that surfaces a desktop alert if beckon exits
-- with non-zero status (typical: app id didn't resolve).
local function beckon(name)
	local task
	task = hs.task.new(beckonPath(), function(exitCode, _stdout, stderr)
		if exitCode ~= 0 then
			local msg = (stderr or ""):gsub("%s+$", "")
			if msg == "" then
				msg = "exit code " .. tostring(exitCode)
			end
			hs.alert.show("beckon " .. name .. ": " .. msg, 3)
		end
	end, { name })
	task:start()
end

function obj:init()
	for _, shortcut in ipairs(defaultShortcuts) do
		hs.hotkey.bind(hyper, shortcut[1], function()
			beckon(shortcut[2])
		end)
	end

	-- hyper + a + <key> → launch from extendShortcuts
	local keymap = {}
	for _, shortcut in ipairs(extendShortcuts) do
		keymap[rb.singleKey(shortcut[1], shortcut[2])] = function()
			beckon(shortcut[2])
		end
	end
	local starter = rb.recursiveBind(keymap)
	hs.hotkey.bind(hyper, "a", starter)
end

return obj
