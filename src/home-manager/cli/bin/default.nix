{ pkgs, ... }:
let
  scriptsPath = ./scripts;
  scriptFiles = builtins.readDir scriptsPath;
in
{
  home.packages = builtins.map (name:
    pkgs.writeShellScriptBin name (builtins.readFile (scriptsPath + "/$${name}"))
  ) (builtins.attrNames scriptFiles);
}