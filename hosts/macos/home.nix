{ config, pkgs, lib, home-manager, ... }:

{
  home.username = builtins.getEnv "USER";  
  home.homeDirectory = builtins.getEnv "HOME";  
  home.stateVersion = "23.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ../../modules/darwin.nix
  ];


  nixpkgs.config.allowUnfree = true;


}

