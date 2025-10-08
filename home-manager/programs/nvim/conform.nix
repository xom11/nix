{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.modules.programs.nvim;
in
  lib.mkIf cfg.enable
  {
    programs.nixvim.plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          javascript = ["prettierd"];
          typescript = ["prettierd"];
          yaml = ["prettierd"];
          json = ["prettierd"];
          markdown = ["prettierd"];
          scss = ["prettierd"];
          css = ["prettierd"];
          nix = ["alejandra"];

          lua = ["stylua"];
          python = ["black"];
          rust = ["rustfmt"];
          sh = ["shfmt"];
          "_" = ["trim_whitespace"];
        };
      };
    };
    programs.nixvvim.keymaps = [
      {
        key = "<leader>lf";
        action = "<cmd>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";

        options = {
          silent = true;
        };
      }
    ];
    home.packages = with pkgs; [
      black
      shfmt
      stylua
      alejandra
      prettierd
    ];
  }
