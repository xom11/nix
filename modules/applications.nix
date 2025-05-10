
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
        gnome-extension-manager
        vscode
        notion
        microsoft-edge
        telegram-desktop
        brave
        google-chrome
    ];
}