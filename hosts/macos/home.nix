{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  imports = [
    ../../modules/macos.nix
  ];

  nixpkgs.config.allowUnfree = true;
}

