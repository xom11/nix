return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  keys = {
    { 
      "<leader>ee", 
      "<cmd>Neotree toggle<cr>", 
      desc = "Toggle Neotree file explorer",
      silent = true 
    },
  },
  opts = {
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
      },
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
  },
}