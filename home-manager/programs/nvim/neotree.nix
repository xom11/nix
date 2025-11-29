{
  config,
  ckModule,
  ...
}:
ckModule config ./.
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
  };
  programs.nixvim.keymaps = [
    {
      key = "<leader>ee";
      action = "<CMD>Neotree toggle<NL>";

      options = {
        desc = "Toggle Neotree file explorer";
        silent = true;
      };
    }
  ];
}
