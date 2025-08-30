{pkgs, lib, config, ...}:
let
  cfg = config.modules.x11;
in
{
  options.modules.x11 ={
    enable = lib.mkEnableOption "Enable x11 settings";
    screen.dpi = lib.mkOption {
      type = lib.types.int;
      default = 144;
      description = "Set screen DPI";
    };
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
    home.file = {
      ".Xresources" = {
        text = ''
          Xft.dpi: ${toString cfg.screen.dpi}
        '';
      };
    };
  };
}