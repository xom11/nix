{ config, pkgs, ... }:

{
  # home.username = builtins.getEnv "USER";  
  # home.homeDirectory = builtins.getEnv "HOME";  

  home.username = "lenamkhanh";
  home.homeDirectory = "/Users/lenamkhanh";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  # user.shell = pkgs.zsh;

  imports = [
    ../../modules/macos.nix
  ];


  nixpkgs.config.allowUnfree = true;


}

