
{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        kitty
        ibus-engines.bamboo
        xdg-desktop-portal 
        xdg-desktop-portal-gtk
        bitwarden
        discord
        vscode
        notion
        microsoft-edge
        telegram-desktop
        brave
        google-chrome
        caprine
        localsend
    ];
}