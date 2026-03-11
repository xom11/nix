{
  config,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file.".claude/commands" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/claude.d/commands";
    };
  }
