vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround" } }, { load = true })
-- https://github.com/kylechui/nvim-surround?tab=readme-ov-file#rocket-usage
-- add, delete, change surroundings (parentheses, brackets, quotes, tags, etc.)
-- use gs instead of s to avoid conflict with leap/flash
require("nvim-surround").setup({})
vim.keymap.set("x", "gs", "<Plug>(nvim-surround-visual)", { desc = "Surround visual" })
