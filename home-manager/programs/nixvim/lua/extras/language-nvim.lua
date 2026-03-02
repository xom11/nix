-- =============================================================================
-- Language Input Switcher for Neovim
-- =============================================================================
--
-- Automatically switches keyboard layout based on Neovim mode:
--   - Normal mode: English
--   - Insert mode: Restore last used layout
--   - Terminal mode: Restore last used layout
--
-- Requirements (one of):
--   - macOS: macism (brew install macism)
--   - Linux: fcitx5-remote (part of fcitx5)
--   - Windows: im-select.exe
--
-- Autocmds:
--   - InsertLeave: Save current layout, switch to English
--   - InsertEnter: Restore last layout
--   - FocusLost: Save current layout
--   - FocusGained: Restore layout if in insert/terminal mode, else English
--
-- NOTE: Using Fcitx5.fcitx5 in macOS keyboard (not Fcitx5.zhHans)
-- =============================================================================
local vim = vim
local api = vim.api
local fn = vim.fn
local uv = vim.loop or vim.uv

local sysname = uv.os_uname().sysname
local is_ssh = vim.env.SSH_TTY ~= nil

local noop = function() end

-- detect platform and available tools
local platform
if sysname == "Darwin" and fn.executable("macism") == 1 and not is_ssh then
	platform = "mac"
elseif sysname == "Linux" and fn.executable("fcitx5-remote") == 1 and not is_ssh then
	platform = "linux"
elseif sysname == "Windows_NT" and fn.executable("im-select.exe") == 1 then
	platform = "windows"
end

if not platform then
	return {
		switch_to_vietnamese = noop,
		switch_to_english = noop,
	}
end

-- layout configurations per platform
local layouts = {
	mac = {
		english = "com.apple.keylayout.ABC",
		vietnamese = "com.apple.keylayout.UnicodeHexInput",
	},
	linux = {
		english = "keyboard-us",
		vietnamese = "unikey",
	},
	windows = {
		english = "1033",
		vietnamese = "1066",
	},
}

local english = layouts[platform].english
local vietnamese = layouts[platform].vietnamese
local last_layout = english

-- command builders per platform
local function build_get_cmd()
	if platform == "mac" then
		return { "macism" }
	elseif platform == "linux" then
		return { "fcitx5-remote", "-n" }
	else
		return { "im-select.exe" }
	end
end

local function build_set_cmd(layout)
	if platform == "mac" then
		return { "macism", layout }
	elseif platform == "linux" then
		return { "fcitx5-remote", "-s", layout }
	else
		return { "im-select.exe", layout }
	end
end

-- async layout operations using vim.system (neovim 0.10+) or vim.fn.jobstart
local function set_layout(layout)
	local cmd = build_set_cmd(layout)
	if vim.system then
		vim.system(cmd, { detach = true })
	else
		fn.jobstart(cmd, { detach = true })
	end
end

local function get_layout_async(callback)
	local cmd = build_get_cmd()
	if vim.system then
		vim.system(cmd, { text = true }, function(obj)
			local result = (obj.stdout or ""):gsub("%s+", "")
			vim.schedule(function()
				callback(result ~= "" and result or english)
			end)
		end)
	else
		local output = {}
		fn.jobstart(cmd, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				output = data
			end,
			on_exit = function()
				local result = table.concat(output, ""):gsub("%s+", "")
				vim.schedule(function()
					callback(result ~= "" and result or english)
				end)
			end,
		})
	end
end

local function switch_to_vietnamese()
	set_layout(vietnamese)
end

local function switch_to_english()
	set_layout(english)
end

local augroup = api.nvim_create_augroup("LanguageSwitch", { clear = true })

api.nvim_create_autocmd("InsertLeave", {
	group = augroup,
	callback = function()
		get_layout_async(function(layout)
			last_layout = layout
		end)
		set_layout(english)
	end,
})

api.nvim_create_autocmd("InsertEnter", {
	group = augroup,
	callback = function()
		set_layout(last_layout)
	end,
})

api.nvim_create_autocmd("FocusLost", {
	group = augroup,
	callback = function()
		get_layout_async(function(layout)
			last_layout = layout
		end)
	end,
})

api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	callback = function()
		local mode = fn.mode()
		if mode == "i" or mode == "t" then
			set_layout(last_layout)
		else
			set_layout(english)
		end
	end,
})

return {
	switch_to_vietnamese = switch_to_vietnamese,
	switch_to_english = switch_to_english,
}
