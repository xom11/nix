{ pkgs, ... }:

{
  imports = [ ../shared ];
  home.packages = with pkgs; [
    dockutil
    # notion-app
    maccy
    raycast
  ];

}