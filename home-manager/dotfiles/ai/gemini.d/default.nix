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
      ".gemini/GEMINI.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/GEMINI.md";
      };
      ".gemini/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/settings.json";
      };
    };
    home.packages = with pkgs; [
      gemini-cli
    ];
  }
