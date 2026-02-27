-- open multiple terminal with different shoruts
-- change language end always go to insert mode when open terminal

local vim = vim
local shell_cmd = vim.o.shell
if vim.fn.has("win32") == 1 then
	if vim.fn.executable("pwsh") == 1 then
		shell_cmd = "pwsh"
	else
		shell_cmd = "powershell"
	end
end

local opts = {
	shell = shell_cmd,
	direction = "float",
	float_opts = {
		border = "curved",
		height = function()
			return math.floor(vim.o.lines * 0.9)
		end,
		width = function()
			return math.floor(vim.o.columns * 0.9)
		end,
	},
	open_mapping = [[<a-t>]],
}

-- change fcitx5 to GoNhanh
local switch_to_vietnamese = require("extras.language-nvim").switch_to_vietnamese
local switch_to_english = require("extras.language-nvim").switch_to_english

-- local switch_to_vietnamese = require("extras.gonhanh").switch_to_vietnamese
-- local switch_to_english = require("extras.gonhanh").switch_to_english

-- delay a bit to fix bug
local function start_insert()
  vim.defer_fn(function()
    vim.cmd("startinsert!")
  end, 50)
end

-- toggle main terminal
vim.keymap.set({ "n", "t" }, "<A-1>", function()
	require("toggleterm.terminal").Terminal
		:new({
			id = 1,
			on_open = function(term)
        start_insert()
				switch_to_english()
			end,
			direction = "float",
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "Toggle main terminal" })

-- toggle claude terminal
vim.keymap.set({ "n", "t" }, "<A-2>", function()
	require("toggleterm.terminal").Terminal
		:new({
			id = 2,
			cmd = "claude",
			on_open = function(term)
        start_insert()
        switch_to_vietnamese()
			end,
			on_close = switch_to_english,
			direction = "float",
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "Toggle claude terminal" })

-- toggle gemini terminal
vim.keymap.set({ "n", "t" }, "<A-3>", function()
	require("toggleterm.terminal").Terminal
		:new({
			id = 3,
			cmd = "gemini",
			on_open = function(term)
        start_insert()
				switch_to_vietnamese()
			end,
			on_close = switch_to_english,
			direction = "float",
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "Toggle gemini terminal" })

-- add hidden=true to separate the terminal from the main terminal list, so that it won't be affected by `open_mapping`

return opts
