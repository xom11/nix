{ pkgs, device, lib, ... }:
lib.mkIf (device == "macmini") {
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
  modules = {
    fonts.enable = true;
  };
}