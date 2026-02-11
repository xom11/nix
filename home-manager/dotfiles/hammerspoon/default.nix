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
      ".hammerspoon/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
      };
      ".hammerspoon/Spoons" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/Spoons";
      };
      ".hammerspoon/LibSpoons" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/LibSpoons";
      };
      ".hammerspoon/MySpoons" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/MySpoons";
      };
    };
  }

