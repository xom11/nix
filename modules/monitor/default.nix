{ config, pkgs, ... }:

{
  systemd.user.services.attic-watch-store = {
    Unit = {
      Description = "Node Exporter for user";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    serviceConfig = {
      ExecStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter --web.listen-address=\":9100\"";
      Restart = "on-failure"; # Tự động khởi động lại nếu Node Exporter gặp lỗi
      RestartSec = "5s";      # Chờ 5 giây trước khi khởi động lại
      # Environment = [ "VAR1=value1" ]; # Có thể thêm biến môi trường nếu cần
    };
  };

  # (Tùy chọn) Nếu bạn muốn Node Exporter luôn được kích hoạt khi khởi động home-manager
  # systemd.user.enable = true; # Đảm bảo systemd user services được kích hoạt
}