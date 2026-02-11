local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("v", ">", ">gv", opts)
map("v", "<", "<gv", opts)

map("v", "J", ":m '>+1<cr>gv=gv", opts)
map("v", "K", ":m '<-2<cr>gv=gv", opts)

map("n", "ga", "ggVG", { desc = "Select all" })

map("v", "<leader>p", '"_dP', { desc = "Paste without overwriting clipboard" })

map("n", "<leader>yy", ":let @+ = expand('%:p')<cr>", { desc = "Copy absolute file path" })
map("n", "<leader>yr", ":let @+ = expand('%:f')<cr>", { desc = "Copy relative file path" })
map("n", "<leader>yf", ":let @+ = expand('%:t')<cr>", { desc = "Copy filename" })

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

map("n", "<leader>en", vim.diagnostic.goto_next, { desc = "Go to next error", silent = true })
map("n", "<leader>ep", vim.diagnostic.goto_prev, { desc = "Go to previous error", silent = true })

map("n", "<leader>es", vim.diagnostic.open_float, { desc = "Show diagnostic error message", silent = true })

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

