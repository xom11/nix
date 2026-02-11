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
      ".config/lazyvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}";
      };
    };
  }
