{
  config,
  getPath,
  mkModule,
  ...
}:
  mkModule config ./. {
    home.file = {
      "${config.xdg.configHome}/sesh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${getPath ./.}";
      };
    };
  }
