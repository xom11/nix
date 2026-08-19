{
  config,
  lib,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  launchApp = import ./launch-app.nix {inherit lib;};
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
      #
      # Sinh CA HAI dinh dang trong giai doan chuyen tu hyprlang sang Lua:
      # hyprland.lua `require` ban .lua, con hyprland.conf `source` ban .conf.
      # Hyprland chi doc mot trong hai cay config (Lua thang neu co mat), nen
      # file thua chi ton vai KB va la duong lui neu phai doi ten hyprland.lua.
      # Xoa dong `.conf` khi nao xoa han cay .conf.
      ".config/hypr-nix/launch-app.lua".text = launchApp.lua;
      ".config/hypr-nix/launch-app.conf".text = launchApp.conf;
    };
  }
