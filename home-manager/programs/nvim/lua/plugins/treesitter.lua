vim = vim
vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } }, { load = true })
-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99


-- Highlighting
vim.filetype.add({
  extension = { kbd = "scheme" }
})

opts = {
	auto_install = true,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
}

require("nvim-treesitter.config").setup(opts)
