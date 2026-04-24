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
    ".config/sway/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
    };
    ".config/sway/conf.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/conf.d";
    };
    ".config/sway/scripts" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/scripts";
    };
  };
  home.packages = with pkgs; [
    libnotify
    acpi
    dunst
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
