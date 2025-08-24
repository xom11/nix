{config, dotfileDir, lib, distro, ...}:
lib.mkIf (distro == "nixos") {
  home.file = {
    ".local/bin" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/bin";
    };
  };
}