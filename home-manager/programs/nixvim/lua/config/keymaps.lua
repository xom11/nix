local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("v", ">", ">gv", opts)
map("v", "<", "<gv", opts)

map("v", "J", ":m '>+1<cr>gv=gv", opts)
map("v", "K", ":m '<-2<cr>gv=gv", opts)

map("n", "gy", ":keepjumps normal! ggVG<cr>", { desc = "Select all", silent = true })

map("v", "<leader>p", '"_dP', { desc = "Paste without overwriting clipboard" })

map("n", "<leader>yy", ":let @+ = expand('%:p')<cr>", { desc = "Copy absolute file path" })
map("n", "<leader>yr", ":let @+ = expand('%:.')<cr>", { desc = "Copy relative file path" })
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

-- <leader>v / vv / <M-v>
map('n', '<leader>v', '<C-v>', { desc = 'Visual Block Mode' })

vim.api.nvim_create_user_command('SortIgnoreComment', function(opts)
    -- 1. Lấy commentstring của file hiện tại (ví dụ: "// %s" hoặc "# %s")
    local cms = vim.bo.commentstring
    if cms == "" then cms = "# %s" end -- Mặc định là # nếu không tìm thấy

    -- 2. Lấy ký hiệu comment (bỏ phần %s và khoảng trắng thừa)
    -- Ví dụ: "// %s" -> "//"
    local comment_part = cms:gsub("%%s.*", ""):gsub("%s+$", "")

    -- 3. Escape các ký tự đặc biệt để Regex không bị lỗi (như / thành \/, * thành \*)
    local escaped_comment = comment_part:gsub("([%/%*%.%^%$%[%]%-%+])", "\\%1")

    -- 4. Xây dựng Regex: ^\s*(ký hiệu comment)?\s*
    -- Regex này sẽ bỏ qua khoảng trắng đầu dòng, sau đó là ký hiệu comment (nếu có), rồi đến khoảng trắng tiếp theo
    local regex = string.format([[^\s*\(%s\)\?\s*]], escaped_comment)

    -- 5. Thực thi lệnh sort trên vùng được chọn (range)
    local command = string.format("%d,%dsort /%s/", opts.line1, opts.line2, regex)
    
    -- Chạy lệnh
    vim.cmd(command)
end, { range = true })


