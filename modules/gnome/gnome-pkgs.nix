{ config
, pkgs
, inputs
, ...
}:
{
  home.packages = with pkgs;[
    gnome-bluetooth

    dconf2nix
    dconf-editor
    preload
    gnome-tweaks

    wmctrl
    xdotool
    xclip

    gnome-boxes
    qemu
  ];
}