
{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        kitty
        preload
        xdg-desktop-portal 
        xdg-desktop-portal-gtk
        bitwarden
        discord
        vscode
        microsoft-edge
        telegram-desktop
        brave
        google-chrome
        caprine
        localsend
        virtualbox
        vlc
        ventoy-full-qt
        ulauncher
    ];
}