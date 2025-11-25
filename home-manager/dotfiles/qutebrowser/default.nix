{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  targetDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/qutebrowser"
    else ".qutebrowser";
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      "${targetDir}/config.py" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.py";
      };
      "${targetDir}/gruvbox.py" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/gruvbox.py";
      };
      "${targetDir}/quickmarks" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/quickmarks";
      };
      "${targetDir}/bookmarks/urls" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/bookmarks/urls";
      };
    };
  }
