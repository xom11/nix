{
  lib,
  pkgs,
  config,
  mkModule,
  ...
}:
  mkModule config ./. {
    home.packages = with pkgs; [
      gnome-extension-manager
      gnome-shell-extensions
      gnome-extensions-cli
      dconf2nix
      dconf-editor

      gnomeExtensions.dash-to-dock
      # gnomeExtensions.run-or-raise
      gnomeExtensions.clipboard-history
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.undecorate
      gnomeExtensions.switcher
      gnomeExtensions.kimpanel
    ];
    # The beckon GNOME Shell extension. Linked into the per-user extensions
    # dir so gnome-shell discovers it on session start. The extension UUID
    # `beckon@xom11.github.io` MUST match the directory name -- gnome-shell
    # uses the path component, not metadata.json's "uuid" field, to bind
    # extension state to dconf entries.
    xdg.dataFile."gnome-shell/extensions/beckon@xom11.github.io".source =
      "${pkgs.beckon-gnome-extension}/share/gnome-shell/extensions/beckon@xom11.github.io";
    # dconf dump /org/gnome/ | dconf2nix
    dconf.settings = lib.mkMerge [
      (import ./shortcuts.nix)
      (import ./system.nix {inherit lib;})
      (import ./extensions.nix {inherit lib;})
      (import ./launch-app.nix {inherit lib;})
    ];
  }
