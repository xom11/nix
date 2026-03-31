-- Language Input Switcher for Neovim
-- Switches to English in Normal mode, restores last layout in Insert/Terminal mode.
-- Requires: macism (macOS), fcitx5-remote (Linux), im-select.exe (Windows)

local api = vim.api
local fn = vim.fn
local uv = vim.loop or vim.uv

local sysname = uv.os_uname().sysname
local is_ssh = vim.env.SSH_TTY ~= nil

-- Kitty SSH: control LOCAL input method via `kitten @` (requires `kitten ssh`)
-- Limitation: can only SET, not GET → no auto-restore on InsertEnter
if is_ssh and vim.env.KITTY_WINDOW_ID then
	local function set_english_local()
		vim.system({
			"kitten", "@", "launch", "--type=background", "sh", "-c",
			"command -v macism >/dev/null 2>&1 && macism 'com.apple.keylayout.UnicodeHexInput'"
				.. " || { command -v fcitx5-remote >/dev/null 2>&1 && fcitx5-remote -s keyboard-us; }",
		}, { detach = true })
	end

	local augroup = api.nvim_create_augroup("LanguageSwitch", { clear = true })

	api.nvim_create_autocmd({ "InsertLeave", "TermLeave" }, {
		group = augroup,
		callback = set_english_local,
	})

	api.nvim_create_autocmd("FocusGained", {
		group = augroup,
		callback = function()
			local mode = fn.mode()
			if mode ~= "i" and mode ~= "t" then
				set_english_local()
			end
		end,
	})

	return {}
end

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

local function set_layout(layout)
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

-- Polling keeps last_layout fresh while in insert/terminal mode.
-- Needed because there is no reliable "leave" event when switching apps
-- without first returning to Normal mode (e.g., directly cmd+tabbing away).
local poll_timer = nil

local function start_poll()
	if poll_timer then return end
	poll_timer = uv.new_timer()
	poll_timer:start(300, 300, function()
		get_layout_async(function(layout) last_layout = layout end)
	end)
end

local function stop_poll()
	if poll_timer then
		poll_timer:stop()
		poll_timer:close()
		poll_timer = nil
	end
end

local augroup = api.nvim_create_augroup("LanguageSwitch", { clear = true })

api.nvim_create_autocmd({ "InsertEnter", "TermEnter" }, {
	group = augroup,
	callback = function()
		set_layout(last_layout)
		start_poll()
	end,
})

api.nvim_create_autocmd({ "InsertLeave", "TermLeave" }, {
	group = augroup,
	callback = function()
		stop_poll()
		last_layout = get_layout_sync()
		set_layout(english)
	end,
})

-- Do not query layout on FocusLost: the system layout may have already changed
-- for the newly focused app before this event fires, giving a wrong value.
-- last_layout is kept as-is from the poll or last Leave event.
api.nvim_create_autocmd("FocusLost", {
	group = augroup,
	callback = stop_poll,
})

api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	callback = function()
		local mode = fn.mode()
		if mode == "i" or mode == "t" then
			set_layout(last_layout)
			start_poll()
		else
			set_layout(english)
		end
	end,
})

return {}
