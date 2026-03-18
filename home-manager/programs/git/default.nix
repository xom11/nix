{
  config,
  mkModule,
  pkgs,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # programs.git.enable = true;

    home.file = {
      ".config/git/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
    };
    home.packages = [pkgs.git];
  }
