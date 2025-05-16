{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        preload
        bitwarden
        discord
        vscode
        microsoft-edge
        telegram-desktop
        brave
        google-chrome
        caprine
        localsend
        vlc
        gnome-tweaks
        alacritty  

        xdg-desktop-portal 
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
    ];
}