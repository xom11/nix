{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    prometheus-node-exporter
    redis
    minio
    ffmpeg
  ];
  systemd.user.services.node-exporter = {
    # Unit = {
    #   Description = "Node Exporter for user";
    # };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter --web.listen-address=\":9100\"";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  systemd.user.services.redis = {
    Unit = {
      Description = "Redis server for user";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.redis}/bin/redis-server";
      Restart = "on-failure";
      Type = "simple";
    };
  };
  systemd.user.services.minio = {
    Unit = {
      Description = "MinIO object storage server for user";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = ''
        ${pkgs.minio}/bin/minio server 
      '';
      Environment = [
        "MINIO_ROOT_USER=admin1234"
        "MINIO_ROOT_PASSWORD=admin1234"
        "MINIO_VOLUMES=/mnt/data"
      ];
    };
  };
}