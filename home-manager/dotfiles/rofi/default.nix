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
      ".config/rofi/config.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.rasi";
      };
      ".config/rofi/theme.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/theme.rasi";
      };
    };
  }
