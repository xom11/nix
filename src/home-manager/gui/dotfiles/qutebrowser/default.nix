{config, pkgs, lib, dotfileDir, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/qutebrowser"
    else ".qutebrowser"; 
in
{
  
  home.file = {
    "${configDir}/config.py" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/qutebrowser/config.py";
    };
    "${configDir}/gruvbox.py" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/qutebrowser/gruvbox.py";
    };
    "${configDir}/quickmarks" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/qutebrowser/quickmarks";
    };
    "${configDir}/bookmarks/urls" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/qutebrowser/bookmarks/urls";
    };
  };
}