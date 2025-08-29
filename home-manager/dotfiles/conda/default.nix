{lib, config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.kitty;
in
{
  options.modules.dotfiles.conda = {
    enable = lib.mkEnableOption "Enable conda dotfiles";
  };
  config = lib.mkIf cfg.enable
  {
    home.file = {
      ".condarc" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/conda/condarc";
      };
    };
  };
}