{ lib, dotfileDir, config, ... }:

let
  dir = builtins.readDir ./. ;
  files = lib.filterAttrs (name: type: name != "default.nix") dir;
in
{
  home.file = lib.mapAttrs (name: type: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/bin/${name}";
    target = ".local/bin/${name}";
  }) files;
}