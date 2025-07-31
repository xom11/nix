{config, pkgs, lib, ...}:
let
  configDir = ".config/run-or-raise";
  dotfileDir = "${config.home.homeDirectory}.nix/src/home-manager/gui/gnome/run-or-raise";
in
{
  home.file = {
    "${configDir}/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/shortcuts.conf";
    };
  };
}