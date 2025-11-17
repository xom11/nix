{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins.telescope = {
    enable = true;

    extensions.ui-select.enable = true;
    extensions.frecency = {
      enable = true;
      # FIX: issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/270
      settings.db_safe_mode = false;
      # Fix: issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/105
      settings.db_validate_threshold = 1;
    };
    extensions.fzf-native.enable = true;
    extensions.file-browser = {
      enable = true;
      settings.hidden = true;
      settings.depth = 9999999999;
      settings.auto_depth = true;
    };
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fb" = "buffers";
      "<leader>fp" = "git_files";
      "<leader>fs" = "grep_string";
      "<leader>fg" = "live_grep";
      "<A-f>" = "live_grep";
      "<leader>fo" = "oldfiles";
    };
    settings.defaults = {
      file_ignore_patterns = [
        "^.git/"
        "^.mypy_cache/"
        "^__pycache__/"
        "^output/"
        "^data/"
        "%.ipynb"
      ];
    };
  };
  programs.nixvim.keymaps = [
    {
      key = "<leader><leader>";
      action = "<cmd>Telescope frecency workspace=CWD<cr>";
    }
  ];
}
