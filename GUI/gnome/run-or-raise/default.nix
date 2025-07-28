{config, pkgs, lib, ...}:
{
  home.file = {
    ".config/run-or-raise/shortcuts.conf" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/GUI/gnome/run-or-raise/shortcuts.conf";
    };
  };
}