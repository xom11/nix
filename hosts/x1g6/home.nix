{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/apps/nixos"
    "gui/dotfiles"
    "gui/fonts"
    "gui/gnome"
    "gui/i18n"

    "cli/pkgs"
    "cli/services"
    "cli/client"
    "cli/programs"
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
    update = "sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6";
  };
}
