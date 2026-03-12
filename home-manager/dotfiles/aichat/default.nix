{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  targetDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/aichat"
    else "Library/Application Support/aichat";
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      "${targetDir}/roles" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/aichat.d/roles";
      };
    };
  }
