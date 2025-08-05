{...}:
{
  programs.nixvim.plugins.transparent = {
    enable = true;
    settings = {
      extraGroups = [
				"Normal",
				"NormalNC",
				"TelescopeBorder",
				"NvimTreeNormal",
				"LualineNormal",
				"FzfLuaBorder",
				"FzfLuaNormal",
				"FzfLuaTitle",
				"FzfLuaPreviewBorder",
				"FzfLuaPreviewNormal",
				"FzfLuaPreviewTitle",
      ];
    };
  };
}