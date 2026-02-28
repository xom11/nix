return {
	-- PART: copilot
	{
		"zbirenbaum/copilot.lua",
		requires = {
			"copilotlsp-nvim/copilot-lsp",
		},
	},
	-- PART: avante
	{
		"yetone/avante.nvim",
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false,
		---@module 'avante'
		---@type avante.Config
		opts = require("opts.avante").opts,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-mini/mini.pick",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp",
			"ibhagwan/fzf-lua",
			"stevearc/dressing.nvim",
			"folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
		},
	},
	-- PART: nvim-cmp
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local cfg = require("opts.cmp")
			cmp.setup(cfg.opts)
			cmp.setup.cmdline(":", cfg.cmdline[":"])
		end,
	},
	-- PART: telescope
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-frecency.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		opts = require("opts.telescope").opts,
		config = require("opts.telescope").config,
	},
	-- PART: conform
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = require("opts.conform"),
	},
	-- PART: treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts = require("opts.treesitter").opts,
	},
	-- PART: treesitter-textobjects
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			vim.g.no_plugin_maps = true
		end,
		config = function()
			require("opts.treesitter-textobjects")
		end,
		move = {
			set_jumps = true,
		},
	},
	-- PART: mason
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	-- PART: gitsigns
	{
		"lewis6991/gitsigns.nvim",
		opts = require("opts.gitsigns"),
	},
	-- PART: diffview
	{
		"sindrets/diffview.nvim",
	},
	-- PART: lazygit
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	-- PART: flash
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = require("opts.flash"),
	},
	-- PART: harpoon
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
		end,
	},
	-- PART: neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		lazy = false,
		opts = require("opts.neotree"),
	},
	-- PART: vim-visual-multi
	{
		"mg979/vim-visual-multi",
	},
	-- PART: vim-tmux-navigator
	{
		"christoomey/vim-tmux-navigator",
		config = function()
			vim.keymap.set("n", "C-h", ":TmuxNavigateLeft<CR>")
			vim.keymap.set("n", "C-j", ":TmuxNavigateDown<CR>")
			vim.keymap.set("n", "C-k", ":TmuxNavigateUp<CR>")
			vim.keymap.set("n", "C-l", ":TmuxNavigateRight<CR>")
		end,
	},
	-- PART: which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
	},
	-- PART: auto-save
	{
		"okuuva/auto-save.nvim",
		version = "^1.0.0",
		cmd = "ASToggle",
		event = { "InsertLeave", "TextChanged" },
		opts = {},
	},
	-- PART: comment
	{
		"numToStr/Comment.nvim",
		opts = function()
			return {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	-- PART: nvim-ts-context-commentstring
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	-- PART: nvim-autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	-- PART: toggleterm
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = require("opts.toggleterm"),
	},
	-- PART: catppuccin
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin")
		end,
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
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},
	-- PART: render-markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = require("opts.render-markdown").opts,
	},
	-- PART: dashboard-nvim
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("dashboard").setup({})
		end,
		dependencies = { { "nvim-tree/nvim-web-devicons" } },
	},
	-- PART: colorizer
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = {},
	},
	-- PART: noice
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
	-- PART: nvim-notify
	{
		"rcarriga/nvim-notify",
		opts = require("opts.nvim-notify").opts,
		config = require("opts.nvim-notify").config,
	},
	-- PART: transparent
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		opts = require("opts.transparent"),
		config = require("opts.transparent").config,
	},
	-- PART: todo-comments
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = require("opts.todo-comments"),
	},
}
