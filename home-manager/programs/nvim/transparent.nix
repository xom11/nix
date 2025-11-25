{
  config,
  ckModule,
  ...
}:
ckModule config ./.
{
  programs.nixvim.plugins.transparent = {
    enable = true;
    luaConfig.post = ''
      require('transparent').clear_prefix('NeoTree')
      require('transparent').clear_prefix('Telescope')

      vim.cmd("highlight Normal guibg=NONE")
      vim.cmd("highlight Lualine guibg=NONE")
      vim.cmd("highlight Lualine guifg=NONE")
      vim.cmd("highlight NormalNC guibg=NONE")
      vim.cmd("highlight CursorLine guibg=NONE")

    '';
    settings = {
      enable = true;
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
}
