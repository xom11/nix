{config, pkgs, lib, ...}:
let 
  dotfileDir = ".nix/src/home-manager/gui/dotfiles/ssh";   
{
  
  home.file = {
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/config";
    };
  };
}