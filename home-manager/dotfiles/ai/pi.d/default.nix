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
      ".pi/agent/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/settings.json";
      };
      ".pi/agent/models.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/models.json";
      };
      ".pi/agent/AGENTS.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/AGENTS.md";
      };
      ".pi/agent/extensions" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/extensions";
      };
    };
    home.packages = with pkgs; [
      pi-coding-agent
    ];
  }
