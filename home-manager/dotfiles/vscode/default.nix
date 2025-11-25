{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  configDir =
    if pkgs.stdenv.hostPlatform.isLinux
    then ".config/Code/User"
    else "Library/Application Support/Code/User";
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      "${configDir}/keybindings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/keybindings.json";
      };
      "${configDir}/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/settings.json";
      };
    };
  }

