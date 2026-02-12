return {
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
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = require("opts.conform"),
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
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
}
