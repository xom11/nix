{config, pkgs, lib, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/qutebrowser"
    else ".qutebrowser"; 
in
{
  
  home.file = {
    "${configDir}/config.py" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${config.home.homeDirectory}/nix/GUI/dotfiles/qutebrowser/config.py";
    };
    "${configDir}/quickmarks" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${config.home.homeDirectory}/nix/GUI/dotfiles/qutebrowser/quickmarks";
    };
  };
}