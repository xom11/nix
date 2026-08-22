{
  lib,
  pkgs,
  config,
  mkModule,
  ...
}: let
  ext = import ./extensions.nix {inherit lib pkgs;};
in
  mkModule config ./. {
    home.packages = with pkgs;
      [
        gnome-extension-manager
        gnome-shell-extensions
        gnome-extensions-cli
        dconf2nix
        dconf-editor
      ]
      ++ ext.packages;
    # dconf dump /org/gnome/ | dconf2nix
    dconf.settings = lib.mkMerge [
      (import ./shortcuts.nix)
      (import ./system.nix {inherit lib;})
      ext.dconf
      (import ./launch-app.nix {inherit lib;})
    ];
  }
