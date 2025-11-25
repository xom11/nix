{
  lib,
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/kitty" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kitty.d";
      };
    };
  }
