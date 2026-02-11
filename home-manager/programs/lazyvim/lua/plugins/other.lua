return {
	{
		"mg979/vim-visual-multi",
	},
	{
		"christoomey/vim-tmux-navigator",
		config = function()
			vim.keymap.set("n", "C-h", ":TmuxNavigateLeft<CR>")
			vim.keymap.set("n", "C-j", ":TmuxNavigateDown<CR>")
			vim.keymap.set("n", "C-k", ":TmuxNavigateUp<CR>")
			vim.keymap.set("n", "C-l", ":TmuxNavigateRight<CR>")
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
    opts = require("opts.which-key"),
	},

	{
		"okuuva/auto-save.nvim",
		version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
		cmd = "ASToggle", -- optional for lazy loading on command
		event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
		opts = {},
	},

	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
    opts = require("opts.toggleterm"),
	},
}
