{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.prometheus-node-exporter
  ];
  systemd.user.services.node-exporter = {
    enable = true;
    Unit = {
      Description = "Node Exporter for user";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter --web.listen-address=\":9100\"";
      Restart = "on-failure"; # Tự động khởi động lại nếu Node Exporter gặp lỗi
      RestartSec = "5s";      # Chờ 5 giây trước khi khởi động lại
      # Environment = [ "VAR1=value1" ]; # Có thể thêm biến môi trường nếu cần
    };
  };

}