final: prev:
let
  contents = builtins.readDir ./.;
  dirs = prev.lib.filterAttrs (name: type: type == "directory") contents;
  mkPackage = name: _: prev.callPackage (./. + "/${name}") {};
in
  prev.lib.mapAttrs mkPackage dirs
