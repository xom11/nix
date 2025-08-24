
{config, pkgs, dotfileDir, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/Code/User"
    else "Library/Application Support/Code/User"; 
in
{
  
  home.file = {
    "${configDir}/keybindings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/vscode/keybindings.json";
    };
    "${configDir}/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/vscode/settings.json";
    };
  };
}