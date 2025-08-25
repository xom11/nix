{ pkgs, ... }:
let
  scripts = builtins.filter (name: name != "default.nix") (builtins.attrNames (builtins.readDir ./.) );
in
{
  home.packages = builtins.map (name:
    pkgs.writeShellScriptBin name (builtins.readFile (./. + "/${name}"))
  ) scripts;
}