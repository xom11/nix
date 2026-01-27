{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources = [
        {name = "luasnip";}
        {name = "nvim_lsp";}
        {name = "path";}
        {name = "buffer";}
        {name = "render-markdown";}
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
              if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
              elseif require("copilot.suggestion").is_visible() then
                require("copilot.suggestion").accept()
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
            # NOTE: similar to zsh
            # - Up/Down to navigate history when no selection
            # - Up/Down to navigate completion when selection
            # - Tab/S-Tab to navigate completion
            __raw = ''
              cmp.mapping.preset.cmdline({
                ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    cmp.complete()
                  end
                end, { "c" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  else
                    fallback()
                  end
                end, { "c" }),

                ["<Up>"] = cmp.mapping(function(fallback)
                  if cmp.visible() and cmp.get_selected_entry() then
                    cmp.select_prev_item()
                  else
                    fallback()
                  end
                end, { "c" }),

                ["<Down>"] = cmp.mapping(function(fallback)
                  if cmp.visible() and cmp.get_selected_entry() then
                    cmp.select_next_item()
                  else
                    fallback()
                  end
                end, { "c" }),

                ["<CR>"] = cmp.mapping(function(fallback)
                  if cmp.visible() and cmp.get_selected_entry() then
                    cmp.confirm({ select = false })
                  else
                    fallback()
                  end
                end, { "c" }),
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
