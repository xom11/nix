local function osc52_clipboard()
  return {
    name = 'osc52-custom',
    copy = {
      ['+'] = function(lines) require('vim.ui.clipboard.osc52').copy('+')(lines) end,
      ['*'] = function(lines) require('vim.ui.clipboard.osc52').copy('*')(lines) end,
    },
    paste = {
      ['+'] = function() return require('vim.ui.clipboard.osc52').paste('+')() end,
      ['*'] = function() return require('vim.ui.clipboard.osc52').paste('*')() end,
    },
  }
end

local function tmux_clipboard()
  return {
    name = 'tmux-custom',
    copy = {
      ['+'] = {'tmux', 'load-buffer', '-w', '-'},
      ['*'] = {'tmux', 'load-buffer', '-w', '-'},
    },
    paste = {
      ['+'] = {'tmux', 'save-buffer', '-'},
      ['*'] = {'tmux', 'save-buffer', '-'},
    },
    cache_enabled = 0,
  }
end

if vim.env.TMUX then
  vim.g.clipboard = tmux_clipboard()
  
elseif vim.env.SSH_CONNECTION then
  local status, _ = pcall(require, 'vim.ui.clipboard.osc52')
  if status then
    vim.g.clipboard = osc52_clipboard()
  end
  
else
  vim.g.clipboard = nil
end

