vim = vim
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

return {
	opts = opts,
}
