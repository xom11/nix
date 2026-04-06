{ lib, config, pkgs, mkModule, ... }:
let
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.) );
in
mkModule config ./. {
    home.packages = builtins.map (name:
      pkgs.writeShellScriptBin name (builtins.readFile (./. + "/${name}"))
    ) scripts;
}
