{config, dotfileDir, lib, device, ...}:
lib.mkIf (device == "x1g6") {
  home.file = {
    ".config/kglobalshortcutsrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kde/kglobalshortcutsrc";
    };
  };
}