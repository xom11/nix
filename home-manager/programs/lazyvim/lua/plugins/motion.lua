return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = require("opts.flash"),
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
		end,
	},
}
