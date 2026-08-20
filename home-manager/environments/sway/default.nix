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
    # NEEDS environments/wayland alongside it, which holds mako, kanshi, swaylock
    # and the shared Wayland packages. This module owns only sway's own files.
    home.file = {
      ".config/sway" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/sway.d";
      };
      # The only GENERATED file here, and it cannot live in ~/.config/sway because
      # that is a whole-directory symlink into the repo.
      ".config/sway-nix/launch-app.conf".text =
        import ./launch-app.nix {inherit lib;};
    };
    home.packages = with pkgs; [
      autotiling
    ];
  }
