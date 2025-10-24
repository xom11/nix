
{lib,config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.aerospace;
in
{
  options.modules.dotfiles.aerospace = {
    enable = lib.mkEnableOption "Enable aerospace dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".aerospace.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/aerospace/aerospace.toml";
      };
    };
  };
}
