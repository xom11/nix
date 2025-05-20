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
        joplin-desktop
        
        brave
        # microsoft-edge
        google-chrome
        chromedriver
        # vivaldi
        # chromium


    ];
}