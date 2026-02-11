{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    # PART: neo-tree.nvim
    neo-tree = {
      enable = true;

      settings = {
        autoCleanAfterSessionRestore = true;
        closeIfLastWindow = true;
        window = {
          position = "right";
          mappings = {
            "<bs>" = "navigate_up";
            "." = "set_root";
            "f" = "fuzzy_finder";
            "/" = "filter_on_submit";
            "h" = "show_help";
            "c" = "copy_to_clipboard";
            "yy" = "copy_path";
            "yf" = "copy_name";
            "yr" = "copy_relative_path";
            "<esc>" = "close_window";
          };
        };
        commands = {
          copy_path = {
            __raw = ''
              function(state)
                local p = state.tree:get_node().path
                vim.fn.setreg("+", p)
                vim.notify("Copied: " .. p)
              end
            '';
          };

          copy_name = {
            __raw = ''
              function(state)
                local n = state.tree:get_node().name
                vim.fn.setreg("+", n)
                vim.notify("Copied: " .. n)
              end
            '';
          };

          copy_relative_path = {
            __raw = ''
              function(state)
                local p = state.tree:get_node().path
                local r = vim.fn.fnamemodify(p, ":.")
                vim.fn.setreg("+", r)
                vim.notify("Copied: " .. r)
              end
            '';
          };
        };
        filesystem = {
          follow_current_file = {
            enabled = true;
          };
          filtered_items = {
            hide_hidden = false;
            hide_dotfiles = false;
            force_visible_in_empty_folder = false;
            hide_gitignored = false;
          };
        };
      };

      luaConfig.post = ''
        local map = vim.keymap.set
        map("n", "<leader>et", "<CMD>Neotree toggle<CR>", { silent = true, desc = "Neotree: toggle sidebar" })
        map("n", "<leader>ee", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })
        map("n", "-", "<CMD>Neotree reveal current<CR>", { silent = true, desc = "Neotree: open buffer" })
      '';
    };
    # PART: oil.nvim
    # remap _ instead of -
    oil = {
      enable = true;
      luaConfig.post = ''
        vim.keymap.set("n", "_", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      '';
    };
  };
}
