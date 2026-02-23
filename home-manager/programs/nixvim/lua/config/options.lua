-- Global variables
vim.g.mapleader = " "

-- General options (vim.opt)
local opt = vim.opt

opt.clipboard = "unnamedplus"

-- Tabs & Indentation
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2

-- Line numbers
opt.number = false
opt.relativenumber = false

-- Enable more colors (24-bit)
opt.termguicolors = true

-- Have a better completion experience
opt.completeopt = { "menuone", "noselect", "noinsert" }

-- Enable mouse
opt.mouse = "a"

opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Save undo history
opt.undofile = true
opt.swapfile = true
opt.backup = false
opt.autoread = true

-- Highlight the current line for cursor
opt.cursorline = true

-- Show line and column when searching
opt.ruler = true

-- Start scrolling when the cursor is X lines away from the top/bottom
opt.scrolloff = 5

-- Diagnostic settings
vim.diagnostic.config({
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = "rounded",
  },
  -- Note on jump severity: This is often used in diagnostic jump functions
  -- but we can define the preference here
})

