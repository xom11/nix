{
  config,
  pkgs,
  lib,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  lb_libs = with pkgs; [
    fontconfig
    mono6
    xorg.libX11
    xorg.libX11.dev
    zlib
    stdenv.cc.cc.lib
  ];
in
  mkModule config ./. {
    home.file = {
      ".config/i3/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
      ".config/i3/scripts" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/scripts";
      };
    };
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
      i3-back
      autotiling
    ];
    services.picom = {
      enable = true;
      vSync = true;
      settings = {
        use-damage = false;
      };
    };
    home.sessionVariables = {
      # LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
      LD_LIBRARY_PATH = lib.makeLibraryPath lb_libs;
    };
  }
