{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./scripts));
  pwd = getPath ./.;
in
mkModule config ./. {
    home.file = {
      ".config/i3/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/config";
      };
    };
    home.packages =
      builtins.map (
        name:
          pkgs.writeShellScriptBin name (builtins.readFile (./scripts + "/${name}"))
      )
      scripts ++ [
      ];
}
