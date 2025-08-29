{lib, config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.sway;
in
{
  options.modules.dotfiles.sway = {
    enable = lib.mkEnableOption "Enable sway dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/sway/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/sway/config";
      };
    };
  };
}
