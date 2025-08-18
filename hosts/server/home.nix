{ pkgs, ... }:
{
  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "base"

    "cli/programs"
    "cli/services"
    "cli/pkgs"
    "cli/os/ubuntu"
  ];

  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
}
