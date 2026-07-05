-- Language Input Switcher for Neovim
-- Switches to English in Normal mode, restores last layout in Insert/Terminal mode.
-- Requires: macism (macOS), fcitx5-remote (Linux), im-select.exe (Windows)

local api = vim.api
local fn = vim.fn
local uv = vim.loop or vim.uv

local sysname = uv.os_uname().sysname
local is_ssh = vim.env.SSH_TTY ~= nil

-- Per-platform tool configuration (local, non-SSH)
local cfg = ({
	Darwin     = fn.executable("macism") == 1 and not is_ssh and {
		english = "com.apple.keylayout.UnicodeHexInput",
		-- english = "org.fcitx.inputmethod.Fcitx5.zhHans",
		-- english = "com.apple.keylayout.ABC",
		get     = { "macism" },
		set     = { "macism" },
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

local function get_layout_async(callback)
	if vim.system then
		vim.system(cfg.get, { text = true }, function(obj)
			local result = (obj.stdout or ""):gsub("%s+", "")
			vim.schedule(function() callback(result ~= "" and result or english) end)
		end)
	else
		local output = {}
		fn.jobstart(cfg.get, {
			stdout_buffered = true,
			on_stdout = function(_, data) output = data end,
			on_exit = function()
				local result = table.concat(output, ""):gsub("%s+", "")
				vim.schedule(function() callback(result ~= "" and result or english) end)
			end,
		})
	end
end

-- Set `vim.g.language_nvim_debug = true` to trace every input-source switch.
-- If the language still flickers while typing but no "[lang] set ..." messages
-- appear, the flicker is the IME's own sub-mode toggle, not this script.
local function set_layout(layout)
	if vim.g.language_nvim_debug then
		vim.schedule(function()
			vim.notify("[lang] set " .. layout .. " (mode=" .. fn.mode() .. ")", vim.log.levels.INFO)
		end)
	end
	local cmd = vim.list_extend(vim.deepcopy(cfg.set), { layout })
	if vim.system then
		vim.system(cmd, { detach = true })
	else
		fn.jobstart(cmd, { detach = true })
	end
end

local function get_layout_sync()
	local result = fn.system(cfg.get):gsub("%s+", "")
	return result ~= "" and result or english
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
		last_layout = get_layout_sync()
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
