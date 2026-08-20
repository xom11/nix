{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # NEEDS environments/wayland alongside it, plus `programs.niri` at the NixOS
    # layer. This module only owns config.
    #
    # Unlike sway/hyprland, nothing is GENERATED here, so there is no sibling
    # directory. The launcher bindings are NOT wired in yet, deliberately.
    #
    # Symlinking the whole directory is safe because niri only WRITES to it when
    # config.kdl is absent (it copies out a default), and the file is in the repo.
    # It writes no settings back -- unlike fcitx5.
    home.file = {
      ".config/niri" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/niri.d";
      };
    };
  }
