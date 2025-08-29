{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins.telescope = {
    enable = true;

    enabledExtensions = [ "ui-select" ];
    extensions.ui-select.enable = true;
    extensions.frecency.enable = false;
    extensions.fzf-native.enable = true;

    extensions.file-browser = {
      enable = true;
      settings.hidden = true;
      settings.depth = 9999999999;
      settings.auto_depth = true;
    };
    keymaps = {
      "<leader><leader>" = "find_files";
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
}
