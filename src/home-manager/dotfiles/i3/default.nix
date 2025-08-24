{lib, pkgs, config, dotfileDir, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  home.file = {
    ".config/i3/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/config";
    };
  };
}
