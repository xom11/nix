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

-- PART: Diagnostics
map("n", "<leader>en", vim.diagnostic.goto_next, { desc = "Go to next error", silent = true })
map("n", "<leader>ep", vim.diagnostic.goto_prev, { desc = "Go to previous error", silent = true })
map("n", "<leader>es", vim.diagnostic.open_float, { desc = "Show diagnostic error message", silent = true })
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

-- <leader>v / vv / <M-v>
map("n", "<leader>v", "<C-v>", { desc = "Visual Block Mode" })

-- Open file in browser (useful for html, md files)
map("n", "<leader>ob", function()
	local file = vim.fn.expand("%:p")
	if file == "" then
		print("No file to open")
		return
	end
	local url = "file://" .. file
	local browser = vim.env.BROWSER
	if browser and browser ~= "" then
		vim.fn.system(browser .. " " .. vim.fn.shellescape(url))
	elseif vim.fn.has("mac") == 1 then
		vim.fn.system("open " .. vim.fn.shellescape(url))
	elseif vim.fn.has("win32") == 1 then
		vim.fn.system('rundll32 url.dll,FileProtocolHandler ' .. vim.fn.shellescape(url))
	else
		vim.fn.system("xdg-open " .. vim.fn.shellescape(url))
	end
end, { desc = "Open file in browser" })

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
