{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
  targetDir = ".config/lazyvim";
in
  mkModule config ./. {
    home.file = {
      "${targetDir}/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/init.lua";
      };
      "${targetDir}/lazy-lock.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/lazy-lock.json";
      };
      # share lua configs between nixvim and lazyvim
      "${targetDir}/lua/config/keymaps.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/config/keymaps.lua";
      };
      "${targetDir}/lua/config/options.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/config/options.lua";
      };
      "${targetDir}/lua/extras" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/extras";
      };
      "${targetDir}/lua/opts" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/../nixvim/lua/opts";
      };
    };
  }
