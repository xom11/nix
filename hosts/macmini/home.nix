{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  imports = [
    ../../GUI/dotfiles
    ../../GUI/apps/macos
    ../../GUI/fonts

    ../../CLI/programs
    ../../CLI/pkgs
    ../../CLI/client
  ];

  nixpkgs.config.allowUnfree = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/nix#macmini";
  };

}


