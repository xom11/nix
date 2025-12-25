return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-frecency.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fp", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep String" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old Files" },
    { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
    { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume Last Search" },
    { "<leader><leader>", "<cmd>Telescope frecency workspace=CWD<cr>", desc = "Frecency (CWD)" },
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        preview = {
          treesitter = false,
        },
        vimgrep_arguments = {
          "rg", "-L", "--color=never", "--no-heading", 
          "--with-filename", "--line-number", "--column", "--smart-case"
        },
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
}