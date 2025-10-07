{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable {
  programs = {
    nixvim = {
      keymaps = [
        {
          key = "<leader>lf";
          action = "<cmd>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";

          options = {
            silent = true;
          };
        }
        {
          key = "<A-e>";
          action = "<CMD>Neotree toggle<NL>";
        }
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
