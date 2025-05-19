{ config, pkgs, inputs, ...}:
{
  imports = [
  ];
  home.packages = with pkgs;[
    wmctrl
    xdotool
    xclip
  ];
}