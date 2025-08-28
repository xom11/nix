{lib, pkgs, config, dotfileDir, device, ... }:
lib.mkIf pkgs.stdenv.isLinux {
  home.file = {
    ".config/i3/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/config";
    };
    ".Xresources" = lib.mkIf (device == "desktop") {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/Xresources";
    };
    ".xinitrc" = lib.mkIf (device == "desktop") {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/xinitrc";
    };
  };
}
