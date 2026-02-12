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

local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fp", "<cmd>Telescope git_files<cr>", { desc = "Git Files" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>", { desc = "Grep String" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "LSP Symbols" })
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "LSP Workspace" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume" })

map("n", "<leader><leader>", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Telescope frecency" })
map("n", "<leader>fc", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", { desc = "Current path" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles only_cwd=true<cr>", { desc = "Oldfiles (CWD)" })

map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "LSP Definitions", silent = true, noremap = true })
map("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP References", silent = true, noremap = true })
map("n", "gD", "<cmd>Telescope lsp_declarations<CR>", { desc = "LSP Declarations", silent = true, noremap = true })

return opts
