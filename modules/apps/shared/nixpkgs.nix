{ pkgs, ... }:
{
    home.packages = with pkgs;
    [
        bitwarden
        discord
        vscode
        telegram-desktop
        localsend
        joplin-desktop
        slack
        
        brave
        google-chrome
        chromedriver
        # vivaldi
        # chromium


    ];
}