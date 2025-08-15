{ config, pkgs, option, ... }:
{
  imports = [
    ./bin
  ];
  home.packages = with pkgs; [
    ffmpeg
    discordchatexporter-cli
    xsel
  ];
}