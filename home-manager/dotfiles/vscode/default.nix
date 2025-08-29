
{lib, config, pkgs, dotfileDir, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/Code/User"
    else "Library/Application Support/Code/User"; 
  cfg = config.modules.dotfiles.vscode;
in
{
  options.modules.dotfiles.vscode = {
    enable = lib.mkEnableOption "Enable vscode dotfiles";
  };
  config = lib.mkIf cfg.enable { 
    home.file = {
      "${configDir}/keybindings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/vscode/keybindings.json";
      };
      "${configDir}/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/vscode/settings.json";
      };
    };
  };
}