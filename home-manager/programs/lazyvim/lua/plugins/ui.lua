return {
  -- PART: catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin")
		end,
	},

  -- PART: toggleterm
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = require("opts.toggleterm"),
	},

  -- PART: lualine
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = { theme = "catppuccin" },
		},
	},

  -- PART: barbecue
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		opts = {
			-- configurations go here
		},
	},

  -- PART: render-markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},

  -- PART: dashboard-nvim
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({
				-- config
			})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},

  -- PART: colorizer
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
		},
	},

  -- PART: noice
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			"rcarriga/nvim-notify",
		},
	},

  -- PART: nvim-notify
	{
		"rcarriga/nvim-notify",
		opts = {
			background_colour = "#000000",
			-- timeout = 3000,
		},
	},

  -- PART: transparent
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
    opts = require("opts.transparent"),
		config = function(_, opts)
			local transparent = require("transparent")

			transparent.setup(opts)

			transparent.clear_prefix("NeoTree")
			transparent.clear_prefix("Telescope")

			vim.cmd("highlight Normal guibg=NONE")
			vim.cmd("highlight Lualine guibg=NONE")
			vim.cmd("highlight Lualine guifg=NONE")
			vim.cmd("highlight NormalNC guibg=NONE")
		end,
	},
}
