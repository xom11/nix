opts =  {
	auto_clean_after_session_restore = true,
	close_if_last_window = true,

	window = {
		position = "right",
		mappings = {
			["<bs>"] = "navigate_up",
			["."] = "set_root",
			["f"] = "fuzzy_finder",
			["/"] = "filter_on_submit",
			["h"] = "show_help",
			["c"] = "copy_to_clipboard",
			["yy"] = "copy_path",
			["yf"] = "copy_name",
			["yr"] = "copy_relative_path",
      ["<esc>"] = "close_window",
		},
	},

	commands = {
		copy_path = function(state)
			local p = state.tree:get_node().path
			vim.fn.setreg("+", p)
			vim.notify("Copied: " .. p)
		end,

		copy_name = function(state)
			local n = state.tree:get_node().name
			vim.fn.setreg("+", n)
			vim.notify("Copied: " .. n)
		end,

		copy_relative_path = function(state)
			local p = state.tree:get_node().path
			local r = vim.fn.fnamemodify(p, ":.")
			vim.fn.setreg("+", r)
			vim.notify("Copied: " .. r)
		end,
	},

	filesystem = {
		follow_current_file = {
			enabled = true,
		},
		filtered_items = {
			hide_hidden = false,
			hide_dotfiles = false,
			force_visible_in_empty_folder = false,
			hide_gitignored = false,
		},
	},
}

local map = vim.keymap.set
map("n", "<leader>et", "<CMD>Neotree toggle<CR>", { silent = true, desc = "Neotree: toggle sidebar" })
map("n", "<leader>ee", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })
map("n", "-", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })

return opts
