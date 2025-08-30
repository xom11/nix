{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources =
        [
          { name = "luasnip"; }
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "render-markdown"; }
        ];

      settings.mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Down>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false })";
        "<Up>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false })";

        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
      };
      cmdline = {
        ":" = {
          mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Down>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false })";
            "<Up>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false })";
          };
          sources = [
            {
              name = "path";
            }
            {
              name = "cmdline";
            }
          ];
        };
      };
    };
  };
}

