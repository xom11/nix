{
  lib,
  config,
  ...
}: let
  cfg = config.modules.programs.nvim;
in
  lib.mkIf cfg.enable {
    programs = {
      nixvim = {
        keymaps = [
          {
            key = ">";
            mode = "v";
            action = ">gv";
          }
          {
            key = "<";
            mode = "v";
            action = "<gv";
          }
          {
            key = "ga";
            action = "ggVG";
            options.desc = "Select all";
          }
          {
            key = "gd";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.definition()<cr>";
            options.desc = "Go to definition";
          }
          {
            key = "<leader>yy";
            mode = "n";
            action = ":let @+ = expand('%:p')<cr>";
            options.desc = "Copy file path to clipboard";
          }
          {
            key = "<leader>yr";
            mode = "n";
            action = ":let @+ = expand('%:f';)<CR>";
            options.desc = "Copy relative path to clipboard";
          }
          {
            key = "<leader>yf";
            mode = "n";
            action = ":let @+ = expand('%:t')<CR>";
            options.desc = "Copy filename to clipboard";
          }
        ];
      };
    };
  }
