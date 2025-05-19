{ config
, pkgs
, inputs
, ...
}:
{
    home.packages = with pkgs;
    [
        bitwarden
        discord
        vscode
        telegram-desktop
        caprine
        localsend
        alacritty  
        # standardnotes
        joplin-desktop
        
        brave
        # microsoft-edge
        google-chrome
        chromedriver
        # vivaldi
        # chromium

        # xdg-desktop-portal 
        # xdg-desktop-portal-gtk
        # xdg-desktop-portal-wlr
    ];
}