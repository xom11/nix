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
      ".codex/AGENTS.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/AGENTS.md";
      };
      ".codex/config.toml" = {
        force = true;
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config.toml";
      };
    };
    home.packages = with pkgs; [
      codex
    ];
  }
