{ config, pkgs, ... }:

{
  systemd.user.services.attic-watch-store = {
    Unit = {
      Description = "Push nix store changes to attic binary cache.";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.writeShellScript "watch-store" ''
        #!/run/current-system/sw/bin/bash
        ATTIC_TOKEN=$(cat ${config.sops.secrets.attic_auth_token.path})
        ${pkgs.attic}/bin/attic login prod https://majiy00-nix-binary-cache.fly.dev $ATTIC_TOKEN
        ${pkgs.attic}/bin/attic use prod
        ${pkgs.attic}/bin/attic watch-store prod:prod
      ''}";
    };
  };

  # (Tùy chọn) Nếu bạn muốn Node Exporter luôn được kích hoạt khi khởi động home-manager
  # systemd.user.enable = true; # Đảm bảo systemd user services được kích hoạt
}