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
