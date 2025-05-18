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
        telegram-desktop
        caprine
        localsend
        vlc
        gnome-tweaks
        alacritty  
        standardnotes
        joplin-desktop
        
        brave
        # microsoft-edge
        google-chrome
        chromedriver
        # vivaldi
        # chromium

        xdg-desktop-portal 
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
    ];
}