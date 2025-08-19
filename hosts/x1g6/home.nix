{ pkgs, ... }:

{
  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "base"
    "gui"
    "cli"
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
