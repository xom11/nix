{lib, config, ...}:
let
  cfg = config.services.gnome;
in
{
  options.services.gnome = {
    enable = lib.mkEnableOption "Enable GNOME desktop environment";
  };
  config = lib.mkIf cfg.enable {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    # Delete core apps
    services.gnome.core-apps.enable = false;
    services.gnome.gnome-keyring.enable = true;
  };
}
