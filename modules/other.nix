{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
      wmctrl
      xdotool
      xclip
      

      flatpak

      noto-fonts
      noto-fonts-emoji
      fira-code

      ibus
    ];
}