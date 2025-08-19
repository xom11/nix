{config, dotfileDir, lib, distro, pkgs, ...}:
lib.mkIf (distro == "nixos") {
  home.packages = with pkgs; [
    # Add any KDE-specific packages here if needed
    kdotool

  ];
  home.file = {
    ".config/kglobalshortcutsrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kde/kglobalshortcutsrc";
    };
  };
}