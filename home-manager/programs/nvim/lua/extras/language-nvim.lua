-- Language Input Switcher for Neovim
-- Switches to English in Normal mode, restores last layout in Insert/Terminal mode.
-- Requires: tongue (macOS), fcitx5-remote (Linux), im-select.exe (Windows)

local api = vim.api
local fn = vim.fn
local uv = vim.loop or vim.uv

local sysname = uv.os_uname().sysname
local is_ssh = vim.env.SSH_TTY ~= nil

-- Per-platform tool configuration (local, non-SSH).
--
-- Every tool obeys the same contract: `get` prints the current token, `set <token>`
-- applies it, and `english` is the token to force in Normal mode.
--
-- macOS speaks in tongue's modes ("vi"/"en"/"zh") instead of raw input-source IDs.
-- That is the whole point of the swap away from macism: selecting a layout only
-- moved one of the two levers, so whether Normal mode really was English depended
-- on which layout the Vietnamese IME happened to ignore. `tongue en` moves both --
-- it selects ABC *and* turns the IME off -- and verifies the machine actually got
-- there before exiting 0.
local cfg = ({
	Darwin     = fn.executable("tongue") == 1 and not is_ssh and {
		english = "en",
		get     = { "tongue" },
		set     = { "tongue" },
		-- What tongue prints when the live layout matches no configured mode.
		-- Feeding it back would just be `tongue unknown` -> exit 2.
		unknown = "unknown",
	},
	Linux      = fn.executable("fcitx5-remote") == 1 and not is_ssh and {
		english = "keyboard-us",
		get     = { "fcitx5-remote", "-n" },
		set     = { "fcitx5-remote", "-s" },
	},
	Windows_NT = fn.executable("im-select.exe") == 1 and {
		english = "1033",
		get     = { "im-select.exe" },
		set     = { "im-select.exe" },
	},
})[sysname]

if not cfg then return {} end

local english     = cfg.english
local last_layout = english

-- The token our most recent `set` asked for, and how many of those are still
-- running. Both are needed because a switch is no longer instantaneous: on macOS
-- `tongue en` stops the IME process and `tongue vi` starts it again, ~200ms during
-- which the OS still reports the *old* mode. Deciding from that stale reading is
-- what makes a quick Esc-then-i conclude "already correct" and strand you in
-- English while inserting. While a switch is in flight we compare against what we
-- asked for; the moment nothing is in flight the OS is authoritative again, so a
-- switch made outside nvim (Hammerspoon hotkeys) is still picked up.
local pending  = nil
local inflight = 0

local function normalize(result)
	result = (result or ""):gsub("%s+", "")
	if result == "" or result == cfg.unknown then return english end
	return result
end

local function get_layout_async(callback)
	if vim.system then
		vim.system(cfg.get, { text = true }, function(obj)
			local result = normalize(obj.stdout)
			vim.schedule(function() callback(result) end)
		end)
	else
		local output = {}
		fn.jobstart(cfg.get, {
			stdout_buffered = true,
			on_stdout = function(_, data) output = data end,
			on_exit = function()
				local result = normalize(table.concat(output, ""))
				vim.schedule(function() callback(result) end)
			end,
		})
	end
end

-- Set `vim.g.language_nvim_debug = true` to trace every input-source switch.
-- If the language still flickers while typing but no "[lang] set ..." messages
-- appear, the flicker is the IME's own sub-mode toggle, not this script.
--
-- Deliberately not detached: the exit callback is what decrements `inflight`, and
-- a detached job is not guaranteed to deliver it. Nothing here outlives nvim by
-- more than the ~200ms the switch itself takes, so there is nothing to detach for.
local function set_layout(layout)
	if vim.g.language_nvim_debug then
		vim.schedule(function()
			vim.notify("[lang] set " .. layout .. " (mode=" .. fn.mode() .. ")", vim.log.levels.INFO)
		end)
	end
	pending = layout
	inflight = inflight + 1
	-- A failed switch needs no repair: `inflight` drops back to 0, so the next
	-- decision reads the machine instead of trusting a mode it never entered.
	local function finished(code)
		inflight = inflight - 1
		if code ~= 0 and vim.g.language_nvim_debug then
			vim.schedule(function()
				vim.notify("[lang] set " .. layout .. " failed (exit " .. code .. ")", vim.log.levels.WARN)
			end)
		end
	end
	local cmd = vim.list_extend(vim.deepcopy(cfg.set), { layout })
	if vim.system then
		vim.system(cmd, {}, function(obj) finished(obj.code) end)
	else
		fn.jobstart(cmd, { on_exit = function(_, code) finished(code) end })
	end
end

local function get_layout_sync()
	return normalize(fn.system(cfg.get))
end

-- Only switch when the current layout actually differs, so we never
-- re-activate an already-correct input source.
--
-- This matters most for CJK input methods whose Chinese/English toggle is an
-- internal sub-mode that macOS exposes as two oscillating input-source IDs
-- (e.g. Apple Pinyin: "com.apple.inputmethod.SCIM.ITABC" <-> "com.apple.keylayout.ABC").
-- Re-selecting such a source mid-composition resets its sub-mode, which is what
-- showed up as the language "flickering" while typing.
local function ensure_layout(layout)
	if inflight > 0 then
		if pending ~= layout then set_layout(layout) end
		return
	end
	get_layout_async(function(current)
		if current ~= layout then set_layout(layout) end
	end)
end

local augroup = api.nvim_create_augroup("LanguageSwitch", { clear = true })

-- Entering insert/terminal: restore the source you last used there, ONCE.
-- No polling and no focus-driven re-setting, so the script never touches the
-- input source while you are actually typing -- that is what fought the IME
-- and caused the ITABC<->ABC flicker.
api.nvim_create_autocmd({ "InsertEnter", "TermEnter" }, {
	group = augroup,
	callback = function()
		ensure_layout(last_layout)
	end,
})

-- Leaving insert/terminal: remember what you were using, then force English so
-- Normal-mode keystrokes are interpreted as commands.
api.nvim_create_autocmd({ "InsertLeave", "TermLeave" }, {
	group = augroup,
	callback = function()
		-- Same staleness rule as ensure_layout: read the machine only when no
		-- switch is in flight, otherwise we would memorise the mode we are
		-- currently leaving rather than the one we were typing in.
		if inflight > 0 and pending ~= nil then
			last_layout = pending
		else
			last_layout = get_layout_sync()
		end
		if last_layout ~= english then set_layout(english) end
	end,
})

-- Returning focus to the window: only force English when NOT in insert/terminal.
-- Never re-set the source while inserting -- the IME candidate window triggers
-- spurious FocusGained events (tmux focus-events), and re-selecting the source
-- mid-composition is exactly what made the language flicker.
api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	callback = function()
		local m = fn.mode():sub(1, 1)
		if m ~= "i" and m ~= "R" and m ~= "t" then
			ensure_layout(english)
		end
	end,
})

return {}
