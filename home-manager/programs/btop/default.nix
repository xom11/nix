{
  config,
  getPath,
  pkgs,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/btop/btop.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/btop.conf";
      };
    };
    home.packages = [pkgs.btop];
  }
