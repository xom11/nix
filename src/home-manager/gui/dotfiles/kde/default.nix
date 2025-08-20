{config, dotfileDir, lib, distro, ...}:
lib.mkIf (distro == "nixos") {
  home.file = {
    ".config/kglobalshortcutsrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kde/kglobalshortcutsrc";
    };
  };
}