{config, pkgs, lib, ...}:
let
  configDir = ".config/run-or-raise";
  dotfileDir = ".nix/src/home-manager/gui/gnome/run-or-raise";
{
  home.file = {
    "${configDir}/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/shortcuts.conf";
    };
  };
}