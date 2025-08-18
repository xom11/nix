{ pkgs, ... }:

{
  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/apps"
    "gui/environment"
    "gui/dotfiles"
    "gui/fonts"

    "cli/os/nixos"
    "cli/pkgs"
    "cli/services"
    "cli/programs"

    "base"
    "secrets"

  ];

  home.packages = with pkgs; [
  ]; 

  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#x1g6
    '';
  };
}
