{ config, pkgs, inputs, ...}:
{
  imports = [
    ./theme
  ];
  home.packages = with pkgs;[
    wmctrl
    xdotool
    xclip
  ];
}