
{lib,config, ...}:
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
        config = builtins.readFile ./kanata.nixos.kbd;
        # configFile = "${dotfileDir}/kanata/kanata.kbd";
        };
      };
    };
  };
}
