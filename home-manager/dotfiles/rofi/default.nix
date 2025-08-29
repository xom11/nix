{lib,  config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.rofi;
in
{
  options.modules.dotfiles.rofi = {
    enable = lib.mkEnableOption "Enable rofi dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/rofi/config.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/rofi/config.rasi";
      };
      ".config/rofi/theme.rasi" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/rofi/theme.rasi";
      };
    };
  };
}
