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

-- local Terminal = require("toggleterm.terminal").Terminal

-- toggle main terminal
vim.keymap.set({ "n", "t" }, "<A-1>", function()
	require("toggleterm.terminal").Terminal:new({ id = 1, direction = "float", float_opts = opts.float_opts }):toggle()
end, { desc = "Toggle main terminal" })

-- toggle claude terminal
vim.keymap.set({ "n", "t" }, "<A-2>", function()
	require("toggleterm.terminal").Terminal:new({ id = 2, cmd = "claude", direction = "float", float_opts = opts.float_opts }):toggle()
end, { desc = "Toggle claude terminal" })

-- toggle gemini terminal
vim.keymap.set({ "n", "t" }, "<A-3>", function()
  require("toggleterm.terminal").Terminal:new({ id = 3, cmd = "gemini", direction = "float", float_opts = opts.float_opts }):toggle()
end, { desc = "Toggle gemini terminal" })

-- add hidden=true to separate the terminal from the main terminal list, so that it won't be affected by `open_mapping`

return opts
