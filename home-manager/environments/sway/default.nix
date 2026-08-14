{
  config,
  lib,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # CAN environments/wayland bat kem: mako, kanshi, swaylock va toan bo goi
    # Wayland dung chung nam o do. Module nay chi con thu rieng cua sway.
    home.file = {
      ".config/sway" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/sway.d";
      };
      # File duy nhat trong bo sway duoc SINH RA. No khong the nam trong
      # ~/.config/sway vi cho do la symlink vao ca thu muc sway.d cua repo.
      ".config/sway-nix/launch-app.conf".text =
        import ./launch-app.nix {inherit lib;};
    };
    home.packages = with pkgs; [
      autotiling
    ];
  }
