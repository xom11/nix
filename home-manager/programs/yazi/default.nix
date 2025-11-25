{
  pkgs,
  config,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/yazi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/yazi.d";
      };
    };
    home.packages = [
      pkgs.yazi
      pkgs.yaziPlugins.smart-enter
    ];
  }
