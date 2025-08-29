{config, lib, pkgs, dotfileDir, ...}:
let
  configDir = if pkgs.stdenv.hostPlatform.isLinux
    then ".config/qutebrowser"
    else ".qutebrowser"; 
  cfg = config.modules.dotfiles.qutebrowser;
in
{
  options.modules.dotfiles.qutebrowser = {
    enable = lib.mkEnableOption "Enable qutebrowser dotfiles";
  };
  config = lib.mkIf cfg.enable {
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
  };
}
