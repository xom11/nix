{ config, pkgs, inputs, ...}:
{
  imports = [
    ./theme.nix
  ];
  home.packages = with pkgs;[
    wmctrl
    xdotool
    xclip
  ];
}