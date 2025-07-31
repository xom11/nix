{config, pkgs, lib, ...}:
let 
  dotfileDir = "${config.home.homeDirectory}/.nix/src/home-manager/gui/dotfiles/ssh";   
in
{
  
  home.file = {
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/config";
    };
  };
}