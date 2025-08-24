{ pkgs, device, lib, ... }:
lib.mkIf (device == "server") {
  home.packages = with pkgs; [
    ffmpeg
    discordchatexporter-cli
    xsel
  ];
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
}