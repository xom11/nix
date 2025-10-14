{lib, config, ...}:
let
  cfg = config.modules.services.desktop-environment;
in
{
  config = lib.mkIf (cfg.enable && cfg.type == "gnome") {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    # Delete core apps
    services.gnome.core-apps.enable = false;
    services.gnome.gnome-keyring.enable = true;
  };
}
