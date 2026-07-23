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
      ".config/opencode/mcp/router-search/server.mjs" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/mcp/router-search/server.mjs";
      };
      ".config/opencode/plugin/router-models.mjs" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/plugin/router-models.mjs";
      };
    };
    home.packages = with pkgs; [
      (pkgs.writeShellScriptBin "router-search-mcp" ''
        exec node "''${HOME}/.config/opencode/mcp/router-search/server.mjs" "$@"
      '')
      opencode
    ];
  }
