local opts = {
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
			["y"] = "none",
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

require("neo-tree").setup(opts)

local map = vim.keymap.set
map("n", "<leader>et", "<CMD>Neotree toggle<CR>", { silent = true, desc = "Neotree: toggle sidebar" })
map("n", "<leader>ee", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })
map("n", "-", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })

local function jump_skip_neotree(dir)
	return function()
		local list, pos = unpack(vim.fn.getjumplist())
		local n, idx = 0, pos + dir
		while idx >= 0 and idx < #list do
			n = n + 1
			local bufnr = list[idx + 1].bufnr
			if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "neo-tree" then break end
			idx = idx + dir
		end
		if n == 0 then return end
		local key = dir < 0 and "<C-o>" or "<C-i>"
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(n .. key, true, false, true), "n", false)
	end
end

local jump_back = jump_skip_neotree(-1)
local jump_fwd  = jump_skip_neotree(1)

map("n", "<C-o>", jump_back, { desc = "Jump back (skip neo-tree)" })
map("n", "<C-i>", jump_fwd, { desc = "Jump forward (skip neo-tree)" })

map("n", "<C-^>", function()
	local alt = vim.fn.bufnr("#")
	if alt ~= -1 and vim.bo[alt].filetype ~= "neo-tree" then
		vim.cmd("b#")
	else
		jump_back()
	end
end, { desc = "Alternate file (skip neo-tree)" })

