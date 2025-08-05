{...}:
{
  programs.nixvim.plugins.transparent = {
    enable = true;
    luaConfig.post = ''
      require('transparent').clear_prefix('NeoTree')
      require('transparent').clear_prefix('Telescope')
      require('transparent').clear_prefix('Lualine')

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