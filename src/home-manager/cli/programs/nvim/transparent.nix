{...}:
{
  programs.nixvim.plugins.transparent = {
    enable = true;
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