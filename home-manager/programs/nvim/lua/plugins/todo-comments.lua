vim.pack.add({ { src = "https://github.com/folke/todo-comments.nvim" } }, { load = true })
-- https://github.com/folke/todo-comments.nvim/
-- Highlight and search for todo comments like TODO, HACK, BUG in your code
local opts = {
	highlight = {
		multiline = false,
	},
	keywords = {
		FIX = {
			alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" },
			color = "error",
			icon = " ",
		},
		HACK = {
			color = "warning",
			icon = " ",
		},
		NOTE = {
			alt = { "INFO" },
			color = "hint",
			icon = " ",
		},
		SECTION = {
			alt = { "CHAPTER", "PART" },
			icon = " ",
		},
		GUIDE = {
			alt = { "DOCS", "DOCUMENTATION" },
			icon = "󰉋 ",
		},
		PERF = {
			alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" },
			icon = " ",
		},
		TEST = {
			alt = { "TESTING", "PASSED", "FAILED" },
			color = "test",
			icon = "⏲ ",
		},
		TODO = {
			color = "info",
			icon = " ",
		},
		WARN = {
			alt = { "WARNING", "XXX" },
			color = "warning",
			icon = " ",
		},
	},
}

require("todo-comments").setup(opts)

local map = vim.keymap.set
map("n", "]t", function()
	require("todo-comments").jump_next()
end, { desc = "Next Todo Comment" })
map("n", "[t", function()
	require("todo-comments").jump_prev()
end, { desc = "Previous Todo Comment" })
map("n", "<leader>fT", "<Cmd>TodoTelescope<CR>", { desc = "Search TODOs across all files" })
map("n", "<leader>ft", "<Cmd>TodoTelescope search_dirs=%:.<CR>", { desc = "Search TODOs in current file" })

