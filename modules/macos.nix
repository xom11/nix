{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  imports = [
    ./kitty
    ./tools
  ];

  nixpkgs.config.allowUnfree = true;
}


