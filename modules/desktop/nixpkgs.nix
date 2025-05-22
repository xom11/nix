{ pkgs, ... }:

{
  home.packages = with pkgs; [
    preload
    bitwarden-desktop
    
    # teamviewer
    # anydesk

    # xdg-desktop-portal 
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr

  ];

}