{lib, config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.kitty;
in
{
  options.modules.dotfiles.kitty = {
    enable = lib.mkEnableOption "Enable kitty dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/kitty/kitty.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/kitty/kitty.conf";
      };
    };
  };
}
