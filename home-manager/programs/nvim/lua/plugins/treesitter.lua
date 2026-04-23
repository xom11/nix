-- Treesitter is installed via nixvim (nix/treesitter.nix)

-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- Highlighting
vim.filetype.add({
  extension = { kbd = "scheme" }
})
