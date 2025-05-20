
{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";  
  home.homeDirectory = builtins.getEnv "HOME";  
  home.stateVersion = "23.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ../modules/macos.nix
  ];


  nixpkgs.config.allowUnfree = true;


}

