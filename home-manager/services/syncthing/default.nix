{lib, config, ... }:
let
  cfg = config.modules.services.syncthing;
in
{
  options.modules.services.syncthing = {
    enable = lib.mkEnableOption "Enable Syncthing service";
  };
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress =  "127.0.0.1:8384";
      # guiAddress =  "0.0.0.0:8384";
    };
  };
}