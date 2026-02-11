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
      "<leader>et", 
      "<cmd>Neotree toggle<cr>", 
      desc = "Neotree: toggle sidebar",
      silent = true 
    },
    { 
      "<leader>ee", 
      "<cmd>Neotree reveal current<cr>", 
      desc = "Neotree: open buffer",
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
        ["yy"] = "copy_path",
        ["yf"] = "copy_name",
        ["yr"] = "copy_relative_path",
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
  },
}
