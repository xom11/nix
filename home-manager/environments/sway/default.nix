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
      ".config/mako/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/mako.d/config";
      };
    };
    home.packages = with pkgs; [
      beckon
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
