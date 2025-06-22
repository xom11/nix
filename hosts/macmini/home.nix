{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  imports = [
    ../../modules/tools
    ../../modules/apps
  ];

  nixpkgs.config.allowUnfree = true;
  home.sessionVariables = {
    NIX_DEVICE = "macmini";
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };
}


