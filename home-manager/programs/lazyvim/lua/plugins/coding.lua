return {
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"L3MON4D3/LuaSnip", -- Engine snippet
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
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		init = function()
			-- Disable entire built-in ftplugin mappings to avoid conflicts.
			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
			vim.g.no_plugin_maps = true

			-- Or, disable per filetype (add as you like)
			-- vim.g.no_python_maps = true
			-- vim.g.no_ruby_maps = true
			-- vim.g.no_rust_maps = true
			-- vim.g.no_go_maps = true
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
}

