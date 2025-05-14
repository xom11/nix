{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
      wmctrl
      xdotool
      xclip
      
      noto-fonts
      noto-fonts-emoji
      fira-code

    ];
}