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
      ".claude/commands" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/commands";
      };
      ".claude/CLAUDE.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/CLAUDE.md";
      };
      ".claude/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/settings.json";
      };
      ".claude/statusline.mjs" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/statusline.mjs";
      };
    };
  }
