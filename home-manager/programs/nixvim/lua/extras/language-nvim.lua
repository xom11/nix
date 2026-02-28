-- set language based on vim mode
-- requires: macism (macOS), fcitx5-remote (Linux), or PowerShell (Windows)
-- NOTE: using Fcitx5.fcitx5 in macos keyboard (not Fcitx5.zhHans)
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
elseif sysname == "Windows_NT" and fn.executable("powershell") == 1 then
	platform = "windows"
end

if not platform then
	return {
		switch_to_vietnamese = noop,
		switch_to_english = noop,
	}
end

-- layout configurations per platform
-- Windows uses Keyboard Layout ID (KLID): 00000409 = English US, 0000042a = Vietnamese
local layouts = {
	mac = {
		english = "com.apple.keylayout.ABC",
		vietnamese = "com.apple.keylayout.UnicodeHexInput",
	},
	linux = {
		english = "keyboard-us",
		vietnamese = "keyboard-vietnamese",
	},
	windows = {
		english = "00000409",
		vietnamese = "0000042a",
	},
}

local english = layouts[platform].english
local vietnamese = layouts[platform].vietnamese
local last_layout = english

-- PowerShell script for Windows keyboard layout switching
local ps_switch = [[
Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class KL{[DllImport("user32.dll")]public static extern IntPtr LoadKeyboardLayout(string k,uint f);[DllImport("user32.dll")]public static extern IntPtr ActivateKeyboardLayout(IntPtr h,uint f);}';
[KL]::ActivateKeyboardLayout([KL]::LoadKeyboardLayout('%s',1),0)
]]

local ps_get = [[
Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class KL{[DllImport("user32.dll")]public static extern IntPtr GetKeyboardLayout(uint t);}';
$l=[KL]::GetKeyboardLayout(0).ToInt64();'{0:x8}' -f ($l -band 0xFFFF -bor (($l -shr 16) -band 0xFFFF) -shl 16)
]]

-- command builders per platform
local function build_get_cmd()
	if platform == "mac" then
		return { "macism" }
	elseif platform == "linux" then
		return { "fcitx5-remote", "-n" }
	else
		return { "powershell", "-NoProfile", "-Command", ps_get }
	end
end

local function build_set_cmd(layout)
	if platform == "mac" then
		return { "macism", layout }
	elseif platform == "linux" then
		return { "fcitx5-remote", "-s", layout }
	else
		return { "powershell", "-NoProfile", "-Command", string.format(ps_switch, layout) }
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

api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	callback = function()
		if fn.mode() == "i" then
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
