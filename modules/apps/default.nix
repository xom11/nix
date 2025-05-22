{ pkgs, ... }:
{
    home.packages = with pkgs;
    [
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
    ];
}