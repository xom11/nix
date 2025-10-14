{lib,config, dotfileDir, pkgs, ...}:
let
  cfg = config.modules.services.kanata;
in
{
  options.modules.services.kanata = {
    enable = lib.mkEnableOption "Enable kanata service";
  };
  config = lib.mkIf cfg.enable{
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        configFile = "${dotfileDir}/kanata/kanata.kbd";
        };
      };
    };
  };
}
