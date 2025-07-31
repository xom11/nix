{config, pkgs, lib, ...}:
let 
  dotfileDir = "${config.home.homedirectory}/.nix/src/home-manager/gui/dotfiles/ssh";   
in
{
  
  home.file = {
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/config";
    };
  };
}