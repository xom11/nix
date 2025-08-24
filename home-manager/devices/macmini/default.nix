{ pkgs, device, lib, ... }:
lib.mkIf (device == "macmini") {
  home.packages = with pkgs; [
    caligula
  ];

  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
}