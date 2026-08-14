{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # Phan dung chung cua MOI phien Wayland. Ton tai vi mot ly do cu the:
    # sway va hyprland cung chay tren rog, va neu ca hai cung khai
    # ~/.config/mako/config thi home-manager bao loi dinh nghia trung ngay
    # luc eval. Tach ra day thay vi de mot module voi tay sang thu muc cua
    # module kia.
    #
    # Module nay KHONG tu bat theo sway/hyprland: moi host tu liet ke day du,
    # theo quy uoc "mot host la mot ban kiem ke" cua repo.
    home.file = {
      ".config/mako/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/mako.d/config";
      };
      ".config/kanshi/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kanshi.d/kanshi.conf";
      };
      ".config/swaylock/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/swaylock.d/config";
      };
    };
    home.packages = with pkgs; [
      beckon
      libnotify
      mako
      wl-clipboard
      brightnessctl
      # `rofi` chu KHONG phai `rofi-wayland`: nixpkgs da gop hai goi, va
      # `rofi-wayland` gio chi la alias nem loi. Ban o day la rofi 2.0.0,
      # upstream da nuot fork Wayland.
      rofi
      grim
      slurp
      swaybg
      swayidle
      # swaylock TUNG THIEU trong module sway du system.conf goi no o bon cho.
      # Trieu chung cu: toi gio tu khoa thi khong khoa gi ca, swayidle chay mot
      # lenh khong ton tai va im lang.
      swaylock
      cliphist
      kanshi
      wtype
      jq
      bluetui
    ];
  }
