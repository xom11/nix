
{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        kitty
        rofi
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
        notion
    ];
}