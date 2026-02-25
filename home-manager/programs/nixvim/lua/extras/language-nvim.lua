-- set language based on vim mode
-- requires macism (macOS) or fcitx5-remote (Linux)

local sysname = vim.loop.os_uname().sysname
local is_mac = sysname == "Darwin" and vim.fn.executable("macism") == 1
local is_linux = sysname == "Linux" and vim.fn.executable("fcitx5-remote") == 1

if not (is_mac or is_linux) then
	return
end

local english = is_mac and "com.apple.keylayout.ABC" or "keyboard-us"
local vietnamese = is_mac and "org.fcitx.inputmethod.Fcitx5.fcitx5" or "keyboard-vietnamese"
local last_layout = english

local function get_layout()
	local cmd = is_mac and "macism" or "fcitx5-remote -n"
	local f = io.popen(cmd)
	if f then
		local result = f:read("*all"):gsub("%s+", "")
		f:close()
		return result
	end
	return english
end

local function set_layout(layout)
	local cmd = is_mac and ("macism " .. layout) or ("fcitx5-remote -s " .. layout)
	os.execute(cmd)
end

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		last_layout = get_layout()
		set_layout(english)
	end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		set_layout(last_layout)
	end,
})

vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		if vim.fn.mode() == "i" then
			set_layout(last_layout)
		else
			set_layout(english)
		end
	end,
})
