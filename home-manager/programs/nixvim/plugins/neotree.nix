{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins.neo-tree = {
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
    };

    filesystem = {
      followCurrentFile.enabled = true;
      filteredItems = {
        hideHidden = false;
        hideDotfiles = false;
        forceVisibleInEmptyFolder = false;
        hideGitignored = false;
      };
    };

    luaConfig.post = ''
      local map = vim.keymap.set
      map("n", "<leader>ee", "<CMD>Neotree toggle<CR>", { silent = true, desc = "Toggle Neotree file explorer" })
    '';
  };
}
