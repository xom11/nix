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
    # NEEDS environments/wayland alongside it, plus `programs.hyprland` at the
    # NixOS layer. This module only owns config.
    home.file = {
      ".config/hypr" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/hypr.d";
      };
      # ~/.config/hypr is a WHOLE-DIRECTORY symlink into the repo, so a generated
      # file cannot live there. hyprland.lua requires the file without a suffix.
      ".config/hypr-nix/launch-app.lua".text = launchApp;
    };
  }
