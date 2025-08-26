{...}:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  # Delete core apps
  services.gnome.core-apps.enable = false;
  services.gnome.gnome-keyring.enable = true;
}