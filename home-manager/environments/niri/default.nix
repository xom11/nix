{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # CAN environments/wayland bat kem (mako, kanshi, swaylock, swayidle, rofi,
    # cliphist, goi chung) va `programs.niri` o tang NixOS (binary + session
    # .desktop cho GDM + xwayland-satellite). Module nay chi lo config.
    #
    # Khac sway/hyprland o mot diem: KHONG co file nao duoc SINH RA o day, nen
    # khong can thu muc `niri-nix/` ben canh. Bo phim launcher tu
    # configs/shortcuts/apps.shared.toml CHUA duoc noi vao (co y, xem README).
    #
    # Symlink ca thu muc vao repo la an toan o day vi niri chi GHI vao
    # ~/.config/niri khi config.kdl chua ton tai (no chep ban mac dinh ra). File
    # da co san trong repo nen nhanh do khong bao gio chay. niri khong ghi
    # nguoc thiet lap nao vao config -- khac fcitx5, xem environments/i18n.
    home.file = {
      ".config/niri" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/niri.d";
      };
    };
  }
