{ pkgs, ... }:

{
  home.packages = with pkgs; [
    preload
    standardnotes
    
    # teamviewer
    # anydesk

    # xdg-desktop-portal 
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr

  ];

}