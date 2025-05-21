
{ config, pkgs, ... }:

{
  # home.username = builtins.getEnv "USER";  
  # home.homeDirectory = builtins.getEnv "HOME";  
  home.username = "kln";
  home.homeDirectory = "/home/kln";
  home.stateVersion = "25.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ../../modules/nixos.nix
    ./flatpak.nix
  ];

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };

}

