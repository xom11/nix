{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  # user.shell = pkgs.zsh;

  imports = [
    ../../modules/macos.nix
  ];

  nixpkgs.config.allowUnfree = true;
}

