{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.prometheus-node-exporter
  ];
  systemd.user.services.node-exporter = {
    # Khối Unit
    # Các tùy chọn của Unit được đặt trực tiếp như các thuộc tính
    # Không cần khối con "Unit =" nếu chỉ có Description
    description = "Node Exporter for user";

    # Khối Install
    install = { # Cần viết thường 'install'
      wantedBy = [ "default.target" ]; # Cần viết thường 'wantedBy'
    };

    # Các tùy chọn của Service
    # KHÔNG CÓ "serviceConfig =" ở đây.
    # Các tùy chọn như ExecStart, Restart, RestartSec được đặt trực tiếp.
    execStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter --web.listen-address=\":9100\"";
    restart = "on-failure"; # Tự động khởi động lại nếu Node Exporter gặp lỗi
    restartSec = "5s";      # Chờ 5 giây trước khi khởi động lại
    # environment = [ "VAR1=value1" ]; # Có thể thêm biến môi trường nếu cần, cũng viết thường
  };

  # Đảm bảo systemd user services được kích hoạt
  # Bạn có thể bỏ qua dòng này nếu nó đã được bật ở nơi khác trong cấu hình của bạn
  # Ví dụ: trong configuration.nix của NixOS hoặc một module home-manager khác
  systemd.user.enable = true;

}