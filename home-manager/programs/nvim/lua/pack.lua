-- vim.pack — Neovim 0.12 built-in plugin manager
-- LSP/Mason not included — will be added via Nix later

local pack = function(src, setup_fn)
  vim.pack.add({ src }, { load = true })
  if setup_fn then setup_fn() end
end

-- PART: colorscheme
pack('https://github.com/catppuccin/nvim', function()
  vim.cmd.colorscheme('catppuccin')
end)

-- PART: dependencies
pack('https://github.com/nvim-tree/nvim-web-devicons')
pack('https://github.com/nvim-lua/plenary.nvim')
pack('https://github.com/MunifTanjim/nui.nvim')

-- PART: treesitter
pack('https://github.com/nvim-treesitter/nvim-treesitter', function()
  require('nvim-treesitter.configs').setup(require('opts.treesitter').opts)
end)
pack('https://github.com/nvim-treesitter/nvim-treesitter-textobjects', function()
  require('opts.treesitter-textobjects')
end)

-- PART: completion
pack('https://github.com/rafamadriz/friendly-snippets')
pack('https://github.com/L3MON4D3/LuaSnip', function()
  require('luasnip.loaders.from_vscode').lazy_load()
end)
pack('https://github.com/hrsh7th/cmp-nvim-lsp')
pack('https://github.com/hrsh7th/cmp-buffer')
pack('https://github.com/hrsh7th/cmp-path')
pack('https://github.com/hrsh7th/cmp-cmdline')
pack('https://github.com/saadparwaiz1/cmp_luasnip')
pack('https://github.com/hrsh7th/nvim-cmp', function()
  local cfg = require('opts.cmp')
  require('cmp').setup(cfg.opts)
  require('cmp').setup.cmdline(':', cfg.cmdline[':'])
end)

-- PART: copilot
pack('https://github.com/zbirenbaum/copilot.lua', function()
  require('copilot').setup(require('opts.copilot-lua').opts)
end)
pack('https://github.com/CopilotC-Nvim/CopilotChat.nvim', function()
  require('CopilotChat').setup(require('opts.copilot-chat').opts)
end)

-- PART: telescope
pack('https://github.com/nvim-telescope/telescope-ui-select.nvim')
pack('https://github.com/nvim-telescope/telescope-frecency.nvim')
pack('https://github.com/nvim-telescope/telescope-fzf-native.nvim')
pack('https://github.com/nvim-telescope/telescope-file-browser.nvim')
pack('https://github.com/nvim-telescope/telescope.nvim', function()
  local tel = require('opts.telescope')
  tel.config(nil, tel.opts)
end)

-- PART: formatter
pack('https://github.com/stevearc/conform.nvim', function()
  require('conform').setup(require('opts.conform'))
end)

-- PART: navigation
pack('https://github.com/folke/flash.nvim', function()
  require('flash').setup(require('opts.flash').settings or require('opts.flash'))
end)
vim.pack.add({
  { src = 'https://github.com/ThePrimeagen/harpoon', version = 'harpoon2' },
}, { load = true })
local harpoon = require('harpoon')
harpoon:setup()
vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = 'Harpoon: add file' })
vim.keymap.set('n', '<leader>hh', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon: toggle menu' })

pack('https://github.com/nvim-neo-tree/neo-tree.nvim', function()
  require('neo-tree').setup(require('opts.neotree'))
end)
pack('https://github.com/christoomey/vim-tmux-navigator')

-- PART: git
pack('https://github.com/lewis6991/gitsigns.nvim', function()
  require('gitsigns').setup(require('opts.gitsigns'))
end)

-- PART: editing
pack('https://github.com/kylechui/nvim-surround', function()
  require('nvim-surround').setup(require('opts.nvim-surround').settings or {})
end)
pack('https://github.com/JoosepAlviste/nvim-ts-context-commentstring')
pack('https://github.com/numToStr/Comment.nvim', function()
  require('Comment').setup({
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
  })
end)
pack('https://github.com/windwp/nvim-autopairs', function()
  require('nvim-autopairs').setup({})
end)
pack('https://github.com/mg979/vim-visual-multi')
pack('https://github.com/okuuva/auto-save.nvim', function()
  require('auto-save').setup({})
end)

-- PART: terminal
pack('https://github.com/akinsho/toggleterm.nvim', function()
  require('toggleterm').setup(require('opts.toggleterm'))
end)

-- PART: ui
pack('https://github.com/nvim-lualine/lualine.nvim', function()
  require('lualine').setup({})
end)
pack('https://github.com/SmiteshP/nvim-navic')
pack('https://github.com/utilyre/barbecue.nvim', function()
  require('barbecue').setup({})
end)
pack('https://github.com/nvimdev/dashboard-nvim', function()
  require('dashboard').setup({})
end)
pack('https://github.com/folke/noice.nvim', function()
  require('noice').setup({})
end)
pack('https://github.com/rcarriga/nvim-notify', function()
  local cfg = require('opts.nvim-notify')
  cfg.config(nil, cfg.opts)
end)
pack('https://github.com/xiyaowong/transparent.nvim', function()
  local cfg = require('opts.transparent')
  cfg.config(nil, cfg.opts)
end)
pack('https://github.com/catgoose/nvim-colorizer.lua', function()
  require('colorizer').setup({})
end)
pack('https://github.com/folke/which-key.nvim', function()
  require('which-key').setup({})
end)
pack('https://github.com/folke/todo-comments.nvim', function()
  require('todo-comments').setup(require('opts.todo-comments'))
end)
pack('https://github.com/MeanderingProgrammer/render-markdown.nvim', function()
  require('render-markdown').setup(require('opts.render-markdown').opts)
end)

-- PART: misc
pack('https://github.com/HakonHarnes/img-clip.nvim', function()
  require('img-clip').setup(require('opts.img-clip'))
end)
pack('https://github.com/tpope/vim-obsession')
pack('https://github.com/tpope/vim-dadbod')
pack('https://github.com/kristijanhusak/vim-dadbod-ui')
pack('https://github.com/kristijanhusak/vim-dadbod-completion')
