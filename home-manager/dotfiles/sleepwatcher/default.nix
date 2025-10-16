
{lib,config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.sleepwatcher;
in
{
  options.modules.dotfiles.sleepwatcher = {
    enable = lib.mkEnableOption "Enable sleepwatcher dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".wakeup" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sleepwatcher/wakeup";
      };
    };
  };
}
