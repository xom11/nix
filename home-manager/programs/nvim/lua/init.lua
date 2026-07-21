-- Windows standalone Neovim init.lua
-- Sources config from ~/.nix/home-manager/programs/nvim/lua

-- Add repo path so require('config.options') etc works
local repo = vim.fn.expand("$USERPROFILE") .. "/.nix/home-manager/programs/nvim"
vim.opt.rtp:append(repo)

require('config.options')

local plugins_ok, plugins_err = pcall(require, 'plugins')
if not plugins_ok then
  vim.schedule(function()
    vim.notify('failed to load plugins:\n' .. tostring(plugins_err), vim.log.levels.ERROR)
  end)
end

require('config.keymaps')
require('extras')
