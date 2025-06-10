{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    prometheus-node-exporter
    redis
  ];
  systemd.user.services.node-exporter = {
    Unit = {
      Description = "Node Exporter for user";
    };
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
      ExecStart = "${pkgs.redis}/bin/redis-server ${pkgs.redis}/etc/redis.conf";
      Restart = "on-failure";
      Type = "simple";
    };
  };

}