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
    ../../modules/tools
    ../../modules/bin
    ../../modules/systemd
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

}

