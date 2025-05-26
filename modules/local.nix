
{ config, pkgs, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  home.sessionVariables.SHELL = "${pkgs.zsh}/bin/zsh";

  imports = [
    ./tools
    ./bin
    ./gnome
    ./desktop
    ./kitty
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.package = pkgs.vanilla-dmz;
  home.pointerCursor.name = "Vanilla-DMZ";

}

