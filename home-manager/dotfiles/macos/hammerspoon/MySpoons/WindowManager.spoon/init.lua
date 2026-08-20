local obj = {}
obj.__index = obj

local hyper = { "cmd", "alt", "ctrl" }

-- Pre-maximize frames by window id. The screen UUID is stored too because frames are
-- ABSOLUTE coordinates: maximize on an external display, unplug it, restore, and the window
-- lands on a screen that no longer exists.
local originalFrames = {}

-- macOS reuses window ids, so this table both grows forever and can hand a dead window's
-- frame to a new one. Pruned lazily rather than via windowDestroyed, whose callback receives
-- the already-destroyed userdata and throws on w:id() every time a window closes.
local function prune()
	for id in pairs(originalFrames) do
		if not hs.window.get(id) then
			originalFrames[id] = nil
		end
	end
end

-- Shared by all three keys: focused window plus its screen's usable frame.
local function withFocused(fn)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local screen = win:screen()
	if not screen then
		return
	end
	fn(win, screen:frame())
end

function obj:init()
	-- In init(), not at top level: top level runs on require, which would mutate a global
	-- hs.window setting merely because this file was loaded.
	hs.window.animationDuration = 0

	hs.hotkey.bind(hyper, ",", function()
		withFocused(function(win, max)
			win:setFrame({ x = max.x, y = max.y, w = max.w / 2, h = max.h })
		end)
	end)

	hs.hotkey.bind(hyper, ".", function()
		withFocused(function(win, max)
			win:setFrame({ x = max.x + (max.w / 2), y = max.y, w = max.w / 2, h = max.h })
		end)
	end)

	-- Toggle Maximize
	hs.hotkey.bind(hyper, "/", function()
		withFocused(function(win, max)
			prune()

			-- Sheets, dialogs and some PWAs have no id; assigning at [nil] throws.
			local id = win:id()
			if not id then
				win:setFrame(max)
				return
			end

			local uuid = win:screen():getUUID()
			local saved = originalFrames[id]

			if saved and saved.screen == uuid then
				win:setFrame(saved.frame)
				originalFrames[id] = nil
			else
				-- Unsaved, or saved for another screen where that frame is meaningless.
				originalFrames[id] = { frame = win:frame(), screen = uuid }
				win:setFrame(max)
			end
		end)
	end)
end

function obj:stop()
	originalFrames = {}
	return self
end

return obj
