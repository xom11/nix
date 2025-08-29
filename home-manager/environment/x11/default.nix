{pkgs, lib, config, ...}:
let
  cfg = config.modules.x11;
in
{
  options.modules.x11 ={
    enable = lib.mkEnableOption "Enable x11 settings";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      autorandr
      feh
      rofi
      bluetui
      xdotool
      xclip
      brightnessctl
      clipmenu
      dragon-drop
      maim
    ];
    services.picom.enable = true;
  };
}