{
  config,
  getPath,
  mkModule,
  ...
}: let
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./scripts));
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.file = {
      ".aerospace.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/aerospace.toml";
      };
    };
    # home.packages = builtins.map (name:
    #   pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"))
    # ) scripts;
  }
