{pkgs,...}:
{

  home.packages = with pkgs;[
    preload
    standardnotes

    # xdg-desktop-portal 
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr
  ];
}