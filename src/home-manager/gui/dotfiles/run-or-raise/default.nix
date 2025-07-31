{config, pkgs, lib,  .dotfileDir, ..}:
let
  configDir = ".config/run-or-raise";
in
{
  home.file = {
    "${configDir}/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/run-or-rise/shortcuts.conf";
    };
  };
}