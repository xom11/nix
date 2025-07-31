{ config, pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.11"; 
  programs.home-manager.enable = true;

  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/fonts"

    "cli/pkgs"
    "cli/programs"
  ];

  nixpkgs.config.allowUnfree = true;
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "kitty";
  };
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --refresh --flake github:kln-os/nix/main#macbook";
  };

}


