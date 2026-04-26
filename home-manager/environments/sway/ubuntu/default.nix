{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file.".config/swaylock/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../swaylock.d/config";
    };
    home.aptPackages = [
      "sway"
      "swaylock"
      "xdg-desktop-portal-wlr"
    ];
  }
