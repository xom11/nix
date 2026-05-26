{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
  aichatDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/aichat"
    else "Library/Application Support/aichat";
in
  mkModule config ./. {
    home.file = {
      "${aichatDir}/roles" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/roles";
      };
    };
  }
