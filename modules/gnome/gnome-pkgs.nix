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
    gnome-tweak

    wmctrl
    xdotool
    xclip
  ];
}