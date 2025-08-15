{ config, dotfileDir, ... }:
{
  home.file = {
    ".config/run-or-raise/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/run-or-raise/shortcuts.conf";
    };
  };
}
