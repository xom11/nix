{lib,config, getPath, pkgs, ...}:
let
  cfg = config.modules.programs.btop;
  pwd = getPath  ./.;
in
{
  options.modules.programs.btop = {
    enable = lib.mkEnableOption "Enable btop";
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
