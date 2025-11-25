{
  config,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".wakeup" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/wakeup";
      };
    };
  }
