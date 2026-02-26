local vim = vim
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("v", ">", ">gv", opts)
map("v", "<", "<gv", opts)

map("v", "J", ":m '>+1<cr>gv=gv", opts)
map("v", "K", ":m '<-2<cr>gv=gv", opts)

map("n", "gy", ":keepjumps normal! ggVG<cr>", { desc = "Select all", silent = true })

map("v", "<leader>p", '"_dP', { desc = "Paste without overwriting clipboard" })

-- PART: Yank
map("n", "<leader>yy", ":let @+ = expand('%:p')<cr>", { desc = "Copy absolute file path" })
map("n", "<leader>yr", ":let @+ = expand('%:.')<cr>", { desc = "Copy relative file path" })
map("n", "<leader>yf", ":let @+ = expand('%:t')<cr>", { desc = "Copy filename" })

-- Copy @file + selection for AI (visual mode)
map("v", "<leader>yp", function()
	vim.cmd('normal! "zy')
	local selected = vim.fn.getreg("z")
	local filepath = vim.fn.expand("%:.")
	local line_start = vim.fn.line("'<")
	local line_end = vim.fn.line("'>")
	local prompt = string.format("@%s\n\nLine %d-%d:\n```\n%s\n```\n", filepath, line_start, line_end, selected)
	vim.fn.setreg("+", prompt)
	vim.notify(string.format("Copied: @%s L%d-%d", filepath, line_start, line_end), vim.log.levels.INFO)
end, { desc = "Copy @file + selection for AI" })

-- Copy @file for AI (normal mode)
map("n", "<leader>yp", function()
	local filepath = vim.fn.expand("%:.")
	vim.fn.setreg("+", "@" .. filepath)
	vim.notify("Copied: @" .. filepath, vim.log.levels.INFO)
end, { desc = "Copy @file for AI" })
map("n", "<leader>ey", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics > 0 then
		local message = diagnostics[1].message
		vim.fn.setreg("+", message)
		print("Copied diagnostic: " .. message)
	else
		print("No diagnostic at cursor")
	end
end, { desc = "Copy diagnostic message to clipboard", silent = true })

-- PART: Diagnostics
map("n", "<leader>en", vim.diagnostic.goto_next, { desc = "Go to next error", silent = true })
map("n", "<leader>ep", vim.diagnostic.goto_prev, { desc = "Go to previous error", silent = true })

map("n", "<leader>es", vim.diagnostic.open_float, { desc = "Show diagnostic error message", silent = true })

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- <leader>v / vv / <M-v>
map("n", "<leader>v", "<C-v>", { desc = "Visual Block Mode" })

vim.api.nvim_create_user_command("SortIgnoreComment", function(opts)
	local cms = vim.bo.commentstring
	if cms == "" then
		cms = "# %s"
	end
	local comment_part = cms:gsub("%%s.*", ""):gsub("%s+$", "")
	local escaped_comment = comment_part:gsub("([%/%*%.%^%$%[%]%-%+])", "\\%1")
	local regex = string.format([[^\s*\(%s\)\?\s*]], escaped_comment)
	local command = string.format("%d,%dsort /%s/", opts.line1, opts.line2, regex)
	vim.cmd(command)
end, { range = true })
