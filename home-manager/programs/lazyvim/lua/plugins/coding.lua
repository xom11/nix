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
		opts = require("opts.telescope"),
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
					frecency = {
						db_safe_mode = false,
						db_validate_threshold = 1,
					},
					file_browser = {
						hidden = true,
						depth = 9999999999,
						auto_depth = true,
					},
				},
			})

			telescope.load_extension("ui-select")
			telescope.load_extension("frecency")
			telescope.load_extension("file_browser")
		end,
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
