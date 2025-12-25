local opt = vim.opt

opt.clipboard = "unnamedplus"

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

opt.number = false
opt.relativenumber = false

opt.termguicolors = true
opt.cursorline = true
opt.ruler = true
opt.scrolloff = 5
opt.mouse = "a"

opt.completeopt = { "menuone", "noselect", "noinsert" }

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.undofile = true
opt.swapfile = true
opt.backup = false 
opt.autoread = true
vim.diagnostic.config({
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end