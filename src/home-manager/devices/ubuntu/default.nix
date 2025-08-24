{ pkgs, device, lib, ... }:
lib.mkIf (device == "server") {
{
  home.packages = with pkgs; [
    ffmpeg
    discordchatexporter-cli
    xsel
  ];
}