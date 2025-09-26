
{lib, config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.karabiner;
in
{
  options.modules.dotfiles.karabiner = {
    enable = lib.mkEnableOption "Enable karabiner dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/karabiner/karabiner.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/karabiner/karabiner.json";
      };
    };
  };
}
