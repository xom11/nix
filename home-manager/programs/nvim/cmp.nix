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
        # "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<CR>" = ''
          cmp.mapping(function(fallback)
            if cmp.get_selected_entry() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end)
        '';
        "<Down>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false })";
        "<Up>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false })";

        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<Tab>" = ''
          cmp.mapping(function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
            else
              fallback()
            end
          end
        )
        '';
      };
      cmdline = {
        ":" = {
          mapping = {
            # __raw = "cmp.mapping.preset.cmdline()";
            __raw = ''
              cmp.mapping.preset.cmdline({
                ["<Up>"] = cmp.mapping({
                  c = function(fallback)
                    if cmp.visible() then
                      return cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select, select = false })
                    end
                    fallback()
                  end,
                }),
                ["<Down>"] = cmp.mapping({
                  c = function(fallback)
                    if cmp.visible() then
                      return cmp.select_next_item({ behavior = cmp.SelectBehavior.Select, select = false })
                    end
                    fallback()
                  end,
                }),
                ["<CR>"] = cmp.mapping({
                  c = function(fallback)
                    if cmp.get_selected_entry() then
                      return cmp.confirm({ select = true })
                    end
                    fallback()
                  end,
                }),
              })
            '';
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

