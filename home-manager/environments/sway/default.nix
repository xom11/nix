{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/sway" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/sway.d";
      };
      ".config/kanshi/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kanshi.d/kanshi.conf";
      };
    };
    home.packages = with pkgs; [
      libnotify
      mako
      wl-clipboard
      brightnessctl
      rofi
      grim
      slurp
      swaybg
      swayidle
      autotiling
      bluetui
      wtype
      cliphist
      kanshi
      jq
    ];
  }
