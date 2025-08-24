{config, dotfileDir, lib, device, ...}:
lib.mkIf (device == "x1g6") {
  home.file = {
    ".local/bin" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/bin";
    };
  };
}