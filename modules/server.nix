{ config, pkgs, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ./tools
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

}

