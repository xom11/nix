{lib,config, dotfileDir, ...}:
let
  cfg = config.modules.dotfiles.btop;
in
{
  options.modules.dotfiles.btop = {
    enable = lib.mkEnableOption "Enable btop dotfiles";
  };
  config = lib.mkIf cfg.enable{
    home.file = {
      ".config/btop/btop.conf" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfileDir}/btop/btop.conf";
      };
    };
    home.packages = [ config.pkgs.btop ];
  };
}
