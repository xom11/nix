{config, lib, getRelPath, ...}:
let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
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
