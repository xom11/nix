{ pkgs, ... }:

{
  home.packages = with pkgs; [
    preload
    bitwarden-desktop
    # discord
    vscode
    telegram-desktop
    localsend
    joplin-desktop
    slack
    thunderbird
    brave
    google-chrome
    chromedriver
    caprine
    # teamviewer
    # anydesk

    xdg-desktop-portal 
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr

  ];

}