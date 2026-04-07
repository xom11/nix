local opts = {
	current_line_blame = false,
	current_line_blame_opts = {
		delay = 500,
	},
}

require("gitsigns").setup(opts)

local map = vim.keymap.set

-- Navigation
map("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next hunk" })
map("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Prev hunk" })

-- Actions (Hunks)
map({ "n", "v" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
map({ "n", "v" }, "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Undo stage hunk" })
map({ "n", "v" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })

-- Actions (Buffer)
map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>", { desc = "Stage buffer" })
map("n", "<leader>hU", function()
    local file = vim.fn.expand("%")
    vim.cmd("!git restore --staged " .. file)
end, { desc = "Undo stage buffer" })
map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "Reset buffer" })

-- Blame
map("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
map("n", "<leader>hB", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle line blame" })

-- Text object
map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Gitsigns select hunk" })

-- Preview
map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })

