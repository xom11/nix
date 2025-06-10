{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    prometheus-node-exporter
    redis
    minio
    ffmpeg
    # minio-client
  ];
  systemd.user.services.node-exporter = {
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
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = ''
        ${pkgs.minio}/bin/minio server \
          --address 0.0.0.0:9000 \
          --console-address :9001 \
          ${config.home.homeDirectory}/.minio/data
      '';
      Environment = [
        "MINIO_ROOT_USER=admin1234"
        "MINIO_ROOT_PASSWORD=admin1234"
      ];
    };
  };
}