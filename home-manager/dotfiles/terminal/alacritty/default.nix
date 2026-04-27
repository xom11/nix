
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
      ".config/alacritty" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/alacritty.d";
      };
    };
  }
