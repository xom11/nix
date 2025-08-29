{pkgs, lib, config, ...}:
let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts ={
    enable = lib.mkEnableOption "Enable font settings";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [ 
        nerd-fonts.dejavu-sans-mono
        nerd-fonts.fira-code
        nerd-fonts.meslo-lg
      ];
    fonts.fontconfig.enable = true;
  };
}