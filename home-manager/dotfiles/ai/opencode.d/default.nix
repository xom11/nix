{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".config/opencode/opencode.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/opencode.json";
      };
      ".config/opencode/OPENCODE.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/OPENCODE.md";
      };
    };
    home.packages = with pkgs; [
      opencode
    ];
  }
