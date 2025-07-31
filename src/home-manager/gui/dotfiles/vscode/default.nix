
{config, pkgs, lib, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/Code/User"
    else "Library/Application Support/Code/User"; 
  dotfileDir = ".nix/src/home-manager/gui/dotfiles/vscode";
in
{
  
  home.file = {
    "${configDir}/keybindings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/keybindings.json";
    };
    "${configDir}/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/settings.json";
    };
  };
}