{ config, pkgs, option, ... }:
{
  imports = [
    ./bin
  ];
  home.packages = with pkgs; [
    # prometheus-node-exporter
    # redis
    # minio
    ffmpeg
    discordchatexporter-cli
  ];
}