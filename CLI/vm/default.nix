{ config, pkgs, option, ... }:
{
  home.packages = with pkgs; [
    # prometheus-node-exporter
    # redis
    # minio
    ffmpeg
    minio-client
    discordchatexporter-cli
  ];
}