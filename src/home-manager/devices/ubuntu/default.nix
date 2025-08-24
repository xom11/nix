{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg
    discordchatexporter-cli
    xsel
  ];
}