{
  config,
  ckModule,
  pkgs,
  ...
}:
ckModule config ./.
{
  programs.nixvim.plugins.telescope = {
    enable = true;

    extensions = {
      ui-select.enable = true;
      frecency = {
        enable = true;
        # FIX: issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/270
        settings.db_safe_mode = false;
        # Fix: issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/105
        settings.db_validate_threshold = 1;
      };
      fzf-native.enable = true;
      file-browser = {
        enable = true;
        settings.hidden = true;
        settings.depth = 9999999999;
        settings.auto_depth = true;
      };
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
    settings = {
      defaults = {
        vimgrep_arguments = ["${pkgs.ripgrep}/bin/rg" "-L" "--color=never" "--no-heading" "--with-filename" "--line-number" "--column" "--smart-case" "--fixed-strings"];
        selection_caret = "  ";
        entry_prefix = "  ";
        layout_strategy = "flex";
        layout_config = {
          horizontal = {
            prompt_position = "bottom";
          };
        };
        sorting_strategy = "ascending";
        set_env.COLORTERM = "truecolor";
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
  };
  programs.nixvim.keymaps = [
    {
      key = "<leader><leader>";
      action = "<cmd>Telescope frecency workspace=CWD<cr>";
    }
  ];
  home.packages = with pkgs; [
    ripgrep
  ];
}
