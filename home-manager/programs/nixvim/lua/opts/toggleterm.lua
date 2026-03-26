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
			return math.floor(vim.o.lines * 0.99)
		end,
		width = function()
			return math.floor(vim.o.columns * 0.99)
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

-- Auto ID generator
local next_id = 1
local function get_next_id()
	local id = next_id
	next_id = next_id + 1
	return id
end

-- Helper to create terminal with auto ID
local function create_term(config)
	local term_opts = vim.tbl_extend("force", {
		id = get_next_id(),
		direction = opts.direction,
		float_opts = opts.float_opts,
	}, config or {})
	
	require("toggleterm.terminal").Terminal:new(term_opts):toggle()
end

-- PART: terminal
vim.keymap.set({ "n" }, "<leader>tt", function()
	create_term({
		on_open = function(term)
			start_insert()
		end,
	})
end, { desc = "ToggleTerm: terminal" })

-- PART: ai agent
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

vim.keymap.set({ "n", "v" }, "<leader>ac", function()
	copy_context_for_ai()
	create_term({
		cmd = "claude --verbose",
		auto_scroll = false,
		on_open = function(term)
			start_insert()
		end,
	})
end, { desc = "ToggleTerm: claude" })

vim.keymap.set({ "n", "v" }, "<leader>ag", function()
	copy_context_for_ai()
	create_term({
		cmd = "gemini",
		auto_scroll = false,
		on_open = function(term)
			start_insert()
		end,
	})
end, { desc = "ToggleTerm: gemini" })

vim.keymap.set({ "n", "v" }, "<leader>ao", function()
	copy_context_for_ai()
	create_term({
		cmd = "copilot",
		auto_scroll = false,
		on_open = function(term)
			start_insert()
		end,
	})
end, { desc = "ToggleTerm: copilot" })

vim.keymap.set({ "n", "v" }, "<leader>aa", function()
	copy_context_for_ai()
	create_term({
		cmd = "opencode",
		auto_scroll = false,
		on_open = function(term)
			start_insert()
		end,
	})
end, { desc = "ToggleTerm: opencode" })

-- PART: git
vim.keymap.set({ "n" }, "<leader>gg", function()
	create_term({
		cmd = "lazygit",
	})
end, { desc = "ToggleTerm: lazygit" })

vim.keymap.set({ "n" }, "<leader>gd", function()
	create_term({
		cmd = "gh-dash",
	})
end, { desc = "ToggleTerm: gh-dash" })

vim.keymap.set({ "n" }, "<leader>hd", function()
	create_term({
		cmd = "git diff | diffnav",
	})
end, { desc = "ToggleTerm: git diff" })

-- PART: other
-- add hidden=true to separate the terminal from the main terminal list, so that it won't be affected by `open_mapping`
-- Auto-scroll is enabled by default but has scrolling bugs when running an agent
-- ESC ESC to exit terminal mode, then ESC again in normal mode to close terminal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("n", "<Esc>", function()
	if vim.bo.buftype == "terminal" then
		vim.cmd("ToggleTerm")
	end
end, { desc = "Close terminal in normal mode" })

return opts
