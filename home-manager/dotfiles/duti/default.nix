{
  config,
  getPath,
  mkModule,
  lib,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/duti" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/duti.d";
      };
    };

    home.activation = {
      duti = lib.hm.dag.entryAfter ["writeBoundary"] ''
        /opt/homebrew/bin/duti ${pwd}/duti.d/config
      '';
    };
  }
