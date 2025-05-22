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
        thunderbird
        
        brave
        google-chrome
        chromedriver
        # vivaldi
        # chromium


    ];
}