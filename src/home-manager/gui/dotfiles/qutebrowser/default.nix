{config, pkgs, lib, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/qutebrowser"
    else ".qutebrowser"; 
  dotfileDir = ".nix/src/home-manager/gui/dotfiles/qutebrowser";
in
{
  
  home.file = {
    "${configDir}/config.py" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/config.py";
    };
    "${configDir}/gruvbox.py" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/gruvbox.py";
    };
    "${configDir}/quickmarks" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/quickmarks";
    };
    "${configDir}/bookmarks/urls" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/bookmarks/urls";
    };
  };
}