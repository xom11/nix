{ config, pkgs, inputs, ...}:
{
  imports = [
    ./fonts.nix
  ];
  home.packages = with pkgs;[
    wmctrl
    xdotool
    xclip
  ];
}