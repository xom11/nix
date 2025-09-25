{config, lib, pkgs, dotfileDir, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/kanata"
    else "Library/Application Support/kanata/kanata.kbd"; 
  cfg = config.modules.dotfiles.kanata;
in
{
  options.modules.dotfiles.kanata = {
    enable = lib.mkEnableOption "Enable kanata dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      "${configDir}/kanata.kbd" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/kanata/kanata.kbd";
      };
    };
  };
}
