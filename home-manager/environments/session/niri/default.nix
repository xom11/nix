{
  config,
  lib,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  launchApp = import ./launch-app.nix {inherit lib; homeDir = config.home.homeDirectory;};
in
  mkModule config ./. {
    # NEEDS environments/wayland alongside it, plus `programs.niri` at the NixOS
    # layer.
    #
    # Symlinking the whole directory is safe: niri only WRITES to it when
    # config.kdl is absent (copies out a default), and writes no settings back
    # -- unlike fcitx5.
    home.file = {
      ".config/niri" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/niri.d";
      };
      ".config/niri-nix/launch-app.kdl".text = launchApp.conf;
      ".config/niri-nix/launch-app.sh" = {
        text = launchApp.script;
        executable = true;
      };
    };
  }
