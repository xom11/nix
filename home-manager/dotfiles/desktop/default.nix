{config, dotfileDir, lib, device, ...}:
lib.mkIf (device == "x1g6") {
  home.file = {
    ".local/share/applications" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/desktop/applications";
    };
    ".local/share/icons" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/desktop/icons";
    };
  };
}