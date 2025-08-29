{lib, config, dotfileDir, ... }:
let
  cfg = config.modules.dotfiles.i3;
in
{
  options.modules.dotfiles.i3 = {
    enable = lib.mkEnableOption "Enable i3 dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/i3/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/i3/config";
      };
    };
  };
}
