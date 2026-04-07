require("config.options")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
		return
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
	spec = {
		{ "zbirenbaum/copilot.lua" },
		{ "HakonHarnes/img-clip.nvim" },
		{
			"epwalsh/obsidian.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"hrsh7th/nvim-cmp",
				"nvim-telescope/telescope.nvim",
			},
		},
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
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
		},
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "MunifTanjim/nui.nvim" },
		{
			"nvim-telescope/telescope.nvim",
			branch = "0.1.x",
			dependencies = {
				"nvim-telescope/telescope-ui-select.nvim",
				"nvim-telescope/telescope-frecency.nvim",
				"nvim-telescope/telescope-file-browser.nvim",
			},
		},
		{
			"stevearc/conform.nvim",
			cmd = { "ConformInfo" },
		},
		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
		},
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
		},
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
		{ "lewis6991/gitsigns.nvim" },
		{ "folke/flash.nvim" },
		{ "ThePrimeagen/harpoon", branch = "harpoon2" },
		{ "nvim-neo-tree/neo-tree.nvim", branch = "v3.x" },
		{ "mg979/vim-visual-multi" },
		{
			"christoomey/vim-tmux-navigator",
			config = function()
				vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>")
				vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>")
				vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>")
				vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>")
			end,
		},
		{ "folke/which-key.nvim" },
		{ "okuuva/auto-save.nvim", version = "^1.0.0" },
		{
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup({
					pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
				})
			end,
		},
		{ "JoosepAlviste/nvim-ts-context-commentstring" },
		{ "windwp/nvim-autopairs", config = true },
		{ "akinsho/toggleterm.nvim", version = "*" },
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000,
			config = function()
				vim.cmd.colorscheme("catppuccin")
			end,
		},
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "catppuccin/nvim" },
			opts = { options = { theme = "catppuccin-mocha" } },
		},
		{
			"utilyre/barbecue.nvim",
			name = "barbecue",
			version = "*",
			dependencies = { "SmiteshP/nvim-navic" },
			opts = {},
		},
		{
			"MeanderingProgrammer/render-markdown.nvim",
			dependencies = { "nvim-mini/mini.nvim" },
		},
		{
			"nvimdev/dashboard-nvim",
			config = function()
				require("dashboard").setup({})
			end,
		},
		{ "catgoose/nvim-colorizer.lua", opts = {} },
		{ "folke/noice.nvim", opts = {} },
		{ "rcarriga/nvim-notify" },
		{ "xiyaowong/transparent.nvim" },
		{ "folke/todo-comments.nvim" },
	},
	install = { colorscheme = { "habamax" } },
})

require("opts")

require("config.keymaps")
require("extras") -- nixvim
