{
  config,
  lib,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # CAN environments/wayland bat kem (mako, kanshi, swaylock, goi chung) va
    # `programs.hyprland` o tang NixOS (binary + session .desktop cho GDM).
    # Module nay chi lo config.
    home.file = {
      ".config/hypr" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/hypr.d";
      };
      # Cung ly do nhu sway: ~/.config/hypr la symlink CA THU MUC vao repo, nen
      # file duoc SINH RA khong the nam trong do.
      ".config/hypr-nix/launch-app.conf".text =
        import ./launch-app.nix {inherit lib;};
    };
  }
