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
      # Duoi `.lua` la bat buoc: hyprland.lua goi
      # `require("~/.config/hypr-nix/launch-app")` va Hyprland tu them duoi
      # (resolveExplicitLuaRequireFile thu BASE, BASE.lua, BASE/init.lua).
      ".config/hypr-nix/launch-app.lua".text = launchApp;
    };
  }
