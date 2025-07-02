{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = [
    ../../GUI/apps/nixos
    ../../GUI/desktop
    ../../GUI/dotfiles
    ../../GUI/fonts
    ../../GUI/gnome
    ../../GUI/i18n

    ../../CLI/pkgs
    ../../CLI/client
    ../../CLI/programs
    ../../CLI/services
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
    update = "sudo nixos-rebuild switch --impure --refresh --flake github:kln-os/nix/main#x1g6";
  };
}
