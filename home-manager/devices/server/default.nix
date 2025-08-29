{ pkgs, device, lib, ... }:
lib.mkIf (device == "server") {
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
  modules = {
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
  };
}