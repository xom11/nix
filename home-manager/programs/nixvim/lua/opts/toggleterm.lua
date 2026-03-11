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

-- delay a bit to fix bug
local function start_insert()
  vim.defer_fn(function()
    vim.cmd("startinsert!")
  end, 50)
end

-- toggle main terminal
vim.keymap.set({ "n" }, "<leader>tt", function()
	require("toggleterm.terminal").Terminal
		:new({
			id = 1,
			on_open = function(term)
        start_insert()
			end,
			direction = opts.direction,
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "ToggleTerm: terminal" })

-- helper to copy context for AI
-- copy @relative_path and selected text in visual mode
local function copy_context_for_ai()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then -- visual, visual line, visual block
		vim.cmd('normal! "zy')
		local selected = vim.fn.getreg("z")
		local filepath = vim.fn.expand("%:.")
		local line_start = vim.fn.line("'<")
		local line_end = vim.fn.line("'>")
		local prompt = string.format("@%s\n\nLine %d-%d:\n```\n%s\n```\n", filepath, line_start, line_end, selected)
		vim.fn.setreg("+", prompt)
	elseif mode == "n" then
		local filepath = vim.fn.expand("%:.")
		vim.fn.setreg("+", "@" .. filepath)
	end
end

-- toggle claude terminal
vim.keymap.set({ "n", "v" }, "<leader>cc", function()
	copy_context_for_ai()
	require("toggleterm.terminal").Terminal
		:new({
			id = 2,
			cmd = "claude --verbose",
			on_open = function(term)
        start_insert()
			end,
			direction = opts.direction,
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "ToggleTerm: claude" })

-- toggle gemini terminal
vim.keymap.set({ "n", "v" }, "<leader>tg", function()
	copy_context_for_ai()
	require("toggleterm.terminal").Terminal
		:new({
			id = 3,
			cmd = "gemini",
			on_open = function(term)
        start_insert()
			end,
			direction = opts.direction,
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "ToggleTerm: gemini" })

-- toggle lazygit terminal
vim.keymap.set({ "n" }, "<leader>gg", function()
	require("toggleterm.terminal").Terminal
		:new({
			id = 4,
			cmd = "lazygit",
			direction = opts.direction,
			float_opts = opts.float_opts,
		})
		:toggle()
end, { desc = "ToggleTerm: lazygit" })

-- add hidden=true to separate the terminal from the main terminal list, so that it won't be affected by `open_mapping`

-- ESC ESC to exit terminal mode, then ESC again in normal mode to close terminal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("n", "<Esc>", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
	end
end, { desc = "Close terminal in normal mode" })

return opts
