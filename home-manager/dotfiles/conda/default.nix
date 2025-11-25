{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".condarc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/condarc";
      };
    };
  }
