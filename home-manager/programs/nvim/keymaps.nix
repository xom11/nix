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
          }
          {
            key = "gd";
            mode = "n";
            action = "<cmd>lua vim.lsp.buf.definition()<cr>";
          }
        ];
      };
    };
  }
