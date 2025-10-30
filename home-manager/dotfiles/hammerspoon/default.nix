{config, lib, pkgs, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.hammerspoon;
in
{
  options.modules.dotfiles.hammerspoon = {
    enable = lib.mkEnableOption "Enable hammerspoon dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".hammerspoon/init.lua" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/hammerspoon/init.lua";
      };
      ".hammerspoon/Spoons" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/hammerspoon/Spoons";
      };
      ".hammerspoon/MySpoons" = {
        source = config.lib.file.mkOutOfStoreSymlink  "${dotfileDir}/hammerspoon/MySpoons";
      };
    };
  };
}