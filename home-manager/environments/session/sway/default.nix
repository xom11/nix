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
    # NEEDS environments/wayland alongside it for the shared Wayland packages.
    home.file = {
      ".config/sway" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/sway.d";
      };
      # The GENERATED files cannot live in ~/.config/sway (whole-directory
      # symlink into the repo). The script keeps bindings one line -- the
      # focus-or-empty-workspace logic would be quoting hell inline.
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
