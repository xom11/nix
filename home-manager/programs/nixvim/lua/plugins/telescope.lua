local opts = {
	defaults = {
		preview = {
			treesitter = false,
		},
		vimgrep_arguments = {
			"rg",
			"-L",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		path_display = { "truncate" },
		selection_caret = "  ",
		entry_prefix = "  ",
		layout_strategy = "flex",
		layout_config = {
			horizontal = {
				prompt_position = "bottom",
			},
			width = 0.99,
			height = 0.99,
		},
		sorting_strategy = "descending",
		set_env = { COLORTERM = "truecolor" },
		file_ignore_patterns = {
			"^.git/",
			"^.mypy_cache/",
			"^__pycache__/",
			"^output/",
			"^data/",
			"%.ipynb",
		},
	},
}

config = function(_, opts)
	local telescope = require("telescope")
	opts.extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown(),
		},
		frecency = {
			auto_validate = true,
			db_safe_mode = false,
			db_validate_threshold = 0,
		},
		file_browser = {
			hidden = true,
			depth = 9999999999,
			auto_depth = true,
		},
	}
	telescope.setup(opts)
	telescope.load_extension("ui-select")
	telescope.load_extension("frecency")
	telescope.load_extension("file_browser")
end

local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Telescope: Find Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Telescope: Buffers" })
map("n", "<leader>fd", "<cmd>Telescope git_status<cr>", { desc = "Telescope: Git Changed Files" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "Telescope: Grep String" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Telescope: Live Grep" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Telescope: LSP Symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Telescope: LSP Workspace" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Telescope: Help Tags" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Telescope: Resume" })
map("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Telescope: Marks" })

map("n", "<leader><leader>", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Telescope: Frecency" })
map("n", "<leader>fc", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", { desc = "Telescope: Current Path" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<cr>", { desc = "Telescope: Oldfiles (CWD)" })
map("n", "<leader>fa", function()
	require("telescope.builtin").find_files({
		prompt_title = "Age Secrets",
		find_command = { "find", ".", "-name", "*.age", "-not", "-path", "./.git/*" },
		attach_mappings = function(_, m)
			m("i", "<CR>", function(buf)
				local entry = require("telescope.actions.state").get_selected_entry(buf)
				require("telescope.actions").close(buf)
				local path = entry[1]:gsub("^%./", "")
				vim.cmd("enew | terminal agenix -e " .. path)
			end)
			return true
		end,
	})
end, { desc = "Telescope: Age Secrets" })

map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Telescope: LSP Definitions", silent = true, noremap = true })
map("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "Telescope: LSP References", silent = true, noremap = true })
map("n", "gD", "<cmd>Telescope lsp_declarations<CR>", { desc = "Telescope: LSP Declarations", silent = true, noremap = true })

config(nil, opts)
