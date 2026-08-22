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
    # layer. This module owns config and the generated launcher bindings.
    #
    # Unlike sway/hyprland there is no conf.d sibling: the binds stay verbatim
    # in niri.d/config.kdl (upstream defaults, decision 14/08/2026) and only
    # the launcher layer is generated, pulled in by one `include` line there.
    #
    # Symlinking the whole directory is safe because niri only WRITES to it when
    # config.kdl is absent (it copies out a default), and the file is in the repo.
    # It writes no settings back -- unlike fcitx5.
    home.file = {
      ".config/niri" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/niri.d";
      };
      # ~/.config/niri is a WHOLE-DIRECTORY symlink into the repo, so generated
      # files cannot live there.
      ".config/niri-nix/launch-app.kdl".text = launchApp.conf;
      ".config/niri-nix/launch-app.sh" = {
        text = launchApp.script;
        executable = true;
      };
    };
  }
