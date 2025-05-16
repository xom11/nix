{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        preload
        # xdg-desktop-portal 
        # xdg-desktop-portal-gtk
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
    ];
}