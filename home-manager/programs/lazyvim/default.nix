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
      ".config/lazyvim/lua/plugins" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lua/plugins";
      };
      ".config/lazyvim/lua/cfg" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lua/cfg";
      };
      ".config/lazyvim/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
      };
      ".config/lazyvim/lazy-lock.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lazy-lock.json";
      };
      # share lua configs between nixvim and lazyvim
      ".config/lazyvim/lua/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/config";
      };
      ".config/lazyvim/lua/extras" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/extras";
      };
      ".config/lazyvim/lua/opts" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/opts";
      };
    };
  }
