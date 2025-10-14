{lib, config, ...}:
let
  cfg = config.modules.services.desktop-environment;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "kde") {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
