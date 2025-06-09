{ config, pkgs, ... }:

{
  # Đảm bảo bạn đã cài đặt Node Exporter thông qua Home Manager
  # hoặc đảm bảo nó nằm trong PATH của người dùng để systemd tìm thấy
  home.packages = [
    pkgs.prometheus-node-exporter
  ];

  # Định nghĩa dịch vụ systemd --user cho Node Exporter
  systemd.user.services.node-exporter = {
    # Mô tả dịch vụ
    description = "Node Exporter for user";

    # Đảm bảo Node Exporter khởi động sau khi mạng đã sẵn sàng
    wantedBy = [ "default.target" ]; # Hoặc "graphical-session.target" nếu bạn dùng GUI

    # Lệnh để chạy Node Exporter
    # home-manager sẽ đảm bảo node_exporter có sẵn trong PATH
    # nhưng bạn vẫn nên chỉ định --web.listen-address
    serviceConfig = {
      ExecStart = "${pkgs.prometheus-node-exporter}/bin/node_exporter --web.listen-address=\":9100\"";
      Restart = "on-failure"; # Tự động khởi động lại nếu Node Exporter gặp lỗi
      RestartSec = "5s";      # Chờ 5 giây trước khi khởi động lại
      # Environment = [ "VAR1=value1" ]; # Có thể thêm biến môi trường nếu cần
    };

    # (Tùy chọn) Nếu bạn muốn dịch vụ này tiếp tục chạy ngay cả khi bạn đăng xuất
    # Điều này yêu cầu logind giữ session của bạn hoạt động.
    # persistence = {
    #   enable = true;
    #   # logindKeepUnit = true; # Đảm bảo logind giữ unit này
    # };
  };

  # (Tùy chọn) Nếu bạn muốn Node Exporter luôn được kích hoạt khi khởi động home-manager
  # systemd.user.enable = true; # Đảm bảo systemd user services được kích hoạt
}