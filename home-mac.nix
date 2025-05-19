
{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";  
  home.homeDirectory = builtins.getEnv "HOME";  
  home.stateVersion = "23.11"; 

  # user.shell = pkgs.zsh;

  imports = [
    ./modules/macos.nix
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

