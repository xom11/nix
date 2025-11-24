{lib, config, getPath, ...}:
let
  pwd = getPath  ./.;
  cfg = config.modules.dotfiles.kitty;
in
{
  options.modules.dotfiles.kitty = {
    enable = lib.mkEnableOption "Enable kitty dotfiles";
  };
  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/kitty" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kitty.d";
      };
    };
  };
}
