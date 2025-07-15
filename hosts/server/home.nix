{ config, pkgs, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = [
    ../../CLI/programs
    ../../CLI/services
    ../../CLI/pkgs
    ../../CLI/bin
    ../../CLI/vm
  ];

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
}

