--- === Tab ===
---
--- The "tab" layer. kanata turns held-Tab into cmd+ctrl+shift, so every binding below
--- is really Tab + <key>.
---
--- Only a keymap now: the substantial parts moved into LibSpoons and declare their own
--- bindHotkeys, so rebinding is a one-line change here.

local obj = {}
obj.__index = obj

local tab = { "cmd", "ctrl", "shift" }

function obj:init()
	hs.hotkey.bind(tab, "r", function()
		hs.reload()
	end)

	hs.hotkey.bind(tab, "h", function()
		hs.toggleConsole()
	end)

	hs.loadSpoon("AClock")
	hs.hotkey.bind(tab, "t", function()
		spoon.AClock:toggleShow()
	end)

	hs.loadSpoon("ABattery")
	hs.hotkey.bind(tab, "p", function()
		spoon.ABattery:toggleShow()
	end)

	-- q = Chinese, w = Vietnamese, e = English
	hs.loadSpoon("LangSwitch"):bindHotkeys({
		zh = { tab, "q" },
		vi = { tab, "w" },
		en = { tab, "e" },
	})

	hs.loadSpoon("Screenshot"):bindHotkeys({ capture = { tab, "s" } })

	hs.loadSpoon("Caffeine"):bindHotkeys({ toggle = { tab, "c" } })

	-- Draw on screen. c and t deliberately collide with Caffeine and AClock: the
	-- modal masks them while drawing and hands them back on exit.
	hs.loadSpoon("Annotate"):bindHotkeys({
		enter = { tab, "d" },
		clear = { tab, "c" },
		toggle = { tab, "t" },
	})

	-- Emoji picker (not enabled)
	-- hs.loadSpoon("Emojis").chooser:rows(15)
	-- hs.loadSpoon("Emojis"):bindHotkeys({ toggle = { tab, "e" } })
end

return obj
