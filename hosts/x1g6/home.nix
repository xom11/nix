{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/apps"
    "gui/environment"
    "gui/dotfiles"
    "gui/fonts"

    "cli/os/nixos"
    "cli/pkgs"
    "cli/base"
    "cli/services"
    "cli/programs"

    "secrect"

  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
  ]; 

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };

  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
}
