{
  config,
  pkgs,
  lib,
  getPath,
  mkModule,
  ...
}:
let
  pwd = getPath ./.;
in
mkModule config ./. {
  home.file = {
    ".config/sway" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}";
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
    swaylock
    swaybg
    autotiling
    bluetui
    wtype
    cliphist
  ];
}
