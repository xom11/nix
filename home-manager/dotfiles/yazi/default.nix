{lib, pkgs, config, dotfileDir, ... }:
{
  home.file = {
    ".config/yazi/yazi.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/yazi.toml";
    };
    ".config/yazi/theme.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/theme.toml";
    };
    ".config/yazi/keymap.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/yazi/keymap.toml";
    };
  };
}
