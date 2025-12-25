local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("v", ">", ">gv", opts)
keymap.set("v", "<", "<gv", opts)

keymap.set("v", "J", ":m '>+1<cr>gv=gv", opts)
keymap.set("v", "K", ":m '<-2<cr>gv=gv", opts)

keymap.set("n", "ga", "ggVG", { desc = "Select all" })

keymap.set("v", "<leader>p", '"_dP', { desc = "Paste without overwriting clipboard" })

keymap.set("n", "<leader>yy", ":let @+ = expand('%:p')<cr>", { desc = "Copy absolute file path" })
keymap.set("n", "<leader>yr", ":let @+ = expand('%:f')<cr>", { desc = "Copy relative file path" })
keymap.set("n", "<leader>yf", ":let @+ = expand('%:t')<cr>", { desc = "Copy filename" })

keymap.set("n", "<leader>ey", function()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if #diagnostics > 0 then
        local message = diagnostics[1].message
        vim.fn.setreg("+", message)
        print("Copied diagnostic: " .. message)
    else
        print("No diagnostic at cursor")
    end
end, { desc = "Copy diagnostic message to clipboard", silent = true })

keymap.set("n", "<leader>en", vim.diagnostic.goto_next, { desc = "Go to next error", silent = true })
keymap.set("n", "<leader>ep", vim.diagnostic.goto_prev, { desc = "Go to previous error", silent = true })

keymap.set("n", "<leader>es", vim.diagnostic.open_float, { desc = "Show diagnostic error message", silent = true })
