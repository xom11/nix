{lib,config, getPath, pkgs, ...}:
let
  cfg = config.modules.dotfiles.btop;
  pwd = getPath  ./.;
in
{
  options.modules.dotfiles.btop = {
    enable = lib.mkEnableOption "Enable btop dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".config/btop/btop.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/btop.conf";
      };
    };
    home.packages = [ pkgs.btop ];
  };
}
