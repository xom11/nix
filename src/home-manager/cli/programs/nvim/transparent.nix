{...}:
{
  programs.nixvim.plugins.transparent = {
    enable = true;
    settings = {
      enable = true;
      extraGroups = [
        "NormalFloat"
        "FloatBorder"
        "TelescopeBorder"
        "NeoTreeNormal"
        "NeoTreeFloatBorder"
      ];
    };
  };
}