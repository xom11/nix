{
  config,
  lib,
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
      # File duy nhat trong bo sway duoc SINH RA. No khong the nam trong
      # ~/.config/sway vi cho do la symlink vao ca thu muc sway.d cua repo.
      ".config/sway-nix/launch-app.conf".text =
        import ./launch-app.nix {inherit lib;};
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
