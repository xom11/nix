{ config, pkgs, ... }:
let 
  username = builtins.getEnv "USER"; 
in
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "cli/programs"
    "cli/services"
    "cli/pkgs"
    "cli/bin"
    "cli/vm"
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

