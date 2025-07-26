{config, pkgs, lib, ...}:
{
  
  home.file = {
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/GUI/dotfiles/ssh/default.nix";
    };
  };
}