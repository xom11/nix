{lib, device, ... }:
let
  cfg = device.services.modules.syncthing;
in
{
  options.services.modules.syncthing = {
    enable = lib.mkEnableOption "Enable Syncthing service";
  };
  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      guiAddress =  "127.0.0.1:8384";
    };
  };
}