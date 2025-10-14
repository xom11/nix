{ config, lib, ibus-bamboo, system, ... }:

let
  bamboo = ibus-bamboo.packages."${system}".default;
  cfg = config.services.ibus;
in
{

  options.services.ibus = {
    enable = lib.mkEnableOption "Enable IBus input method framework";
    };
  };
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = [
        bamboo
      ];
  };
  };
}
