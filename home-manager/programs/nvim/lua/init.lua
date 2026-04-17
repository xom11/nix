-- Ensure vim.pack's data directory is in packpath (Nix-managed neovim may not include it)
local site = vim.fn.stdpath('data') .. '/site'
if not vim.o.packpath:find(site, 1, true) then
  vim.opt.packpath:prepend(site)
end

require('config.options')
require('plugins')
require('config.keymaps')
require('extras')
