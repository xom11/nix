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
      # The GENERATED files here cannot live in ~/.config/sway because that is
      # a whole-directory symlink into the repo. The script exists so bindings
      # stay one line -- the focus-or-empty-workspace logic would be quoting
      # hell inline in swayconfig.
      ".config/sway-nix/launch-app.conf".text =
        (import ./launch-app.nix {inherit lib;}).conf;
      ".config/sway-nix/launch-app.sh" = {
        text = (import ./launch-app.nix {inherit lib;}).script;
        executable = true;
      };
    };
    home.packages = with pkgs; [
      autotiling
    ];
  }
