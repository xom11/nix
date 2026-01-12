{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    lualine.enable = true;
    render-markdown.enable = true;
    dashboard.enable = true;
    colorizer.enable = true;
    noice.enable = true;
    image.enable = true;
    barbecue.enable = true;
    notify = {
      enable = true;
      settings = {
        background_colour = "#000000";
      };
    };
    transparent = {
      enable = true;
      luaConfig.post = ''
        require('transparent').clear_prefix('NeoTree')
        require('transparent').clear_prefix('Telescope')

        vim.cmd("highlight Normal guibg=NONE")
        vim.cmd("highlight Lualine guibg=NONE")
        vim.cmd("highlight Lualine guifg=NONE")
        vim.cmd("highlight NormalNC guibg=NONE")
        -- Highlight for cursor line
        -- vim.cmd("highlight CursorLine guibg=NONE")

      '';
      settings = {
        enable = true;
        # table: groups you don't want to clear
        exclude_groups = [
          "CursorLine"
        ];
        # table: additional groups that should be cleared
        extra_groups = [
          "NeoTreeNormal"
          "NeoTreeNormalNC"
          "NeoTreeFloat"
          "NeoTreeFloatBorder"

          "TelescopeNormal"
          "TelescopeBorder"
          "TelescopePromptNormal"
          "TelescopePromptBorder"
          "TelescopeResultsNormal"
          "TelescopePreviewNormal"

          "LualineNormal"
          "LualineNC"

          "FzfLuaBorder"
          "FzfLuaNormal"
          "FzfLuaTitle"
          "FzfLuaPreviewBorder"
          "FzfLuaPreviewNormal"
          "FzfLuaPreviewTitle"
        ];
      };
    };
  };
}
