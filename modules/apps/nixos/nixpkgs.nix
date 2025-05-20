{pkgs,...}:
{
with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  preload
  standardnotes
  
  # teamviewer
  # anydesk

  # xdg-desktop-portal 
  # xdg-desktop-portal-gtk
  # xdg-desktop-portal-wlr

]