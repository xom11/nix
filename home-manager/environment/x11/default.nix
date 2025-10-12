{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.x11;
  lb_libs = with pkgs; [
    fontconfig
    mono6
    xorg.libX11
    xorg.libX11.dev
    zlib
    stdenv.cc.cc.lib
  ];
in
{
  options.modules.x11 = {
    enable = lib.mkEnableOption "Enable x11 settings";
    screen.dpi = lib.mkOption {
      type = lib.types.int;
      default = 144;
      description = "Set screen DPI [96, 144, 192]";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xorg.xmodmap
      libnotify
      acpi
      dunst
      autorandr
      arandr
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

    # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    home.sessionVariables = {
      LD_LIBRARY_PATH = lib.makeLibraryPath lb_libs;
    };
  };
}
