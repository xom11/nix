{lib, pkgs, config, dotfileDir, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  home.file = {
    ".config/run-or-raise/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/run-or-raise/shortcuts.conf";
    };
  };
}
