-- https://github.com/kylechui/nvim-surround?tab=readme-ov-file#rocket-usage
-- add, delete, change surroundings (parentheses, brackets, quotes, tags, etc.)
--
-- v4 sets its keymaps from plugin/nvim-surround.lua at source time, NOT from
-- setup() -- so these globals must be set before vim.pack.add loads it, and
-- passing `keymaps` to setup() would only raise an error.
--
-- The defaults (s, S, ds, cs, ys) are exactly the keys flash.lua wants, so
-- surround lives under `gs` instead and flash keeps the single-letter ones.
vim.g.nvim_surround_no_normal_mappings = true
vim.g.nvim_surround_no_visual_mappings = true

vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround" } }, { load = true })

require("nvim-surround").setup({})

local map = vim.keymap.set

-- normal: gs is a prefix (`gsa iw "` surrounds a word with quotes)
map("n", "gsa", "<Plug>(nvim-surround-normal)", { desc = "Surround motion" })
map("n", "gss", "<Plug>(nvim-surround-normal-cur)", { desc = "Surround line" })
map("n", "gsA", "<Plug>(nvim-surround-normal-line)", { desc = "Surround motion, on new lines" })
map("n", "gsd", "<Plug>(nvim-surround-delete)", { desc = "Delete surround" })
map("n", "gsc", "<Plug>(nvim-surround-change)", { desc = "Change surround" })
map("n", "gsC", "<Plug>(nvim-surround-change-line)", { desc = "Change surround, on new lines" })

-- visual: gs acts on the selection
map("x", "gs", "<Plug>(nvim-surround-visual)", { desc = "Surround selection" })
map("x", "gS", "<Plug>(nvim-surround-visual-line)", { desc = "Surround selection, on new lines" })
