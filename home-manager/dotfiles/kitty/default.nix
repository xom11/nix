{
  libx,
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = libx.getPath ./.;
in
  libx.mkModule config ./. {
    home.file = {
      ".config/kitty" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kitty.d";
      };
    };
  }
