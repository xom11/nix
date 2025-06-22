{ config, pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11"; 

  imports = [
    ../../modules/desktop
    ../../modules/gnome
    ../../modules/bin
    ../../modules/sway
    ../../modules/tools
    ../../modules/apps
  ];

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    discordchatexporter-cli
  ]; 

  # Environment
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
    GTK_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    QT_IM_MODULE = "ibus";
  };
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/nix#x1g6";
  };
}
