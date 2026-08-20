{
  config,
  lib,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # GDM moved to dm-gdm.nix. This file used to enable both, so dropping gnome
  # also dropped the login screen -- a coupling nobody intended. This now owns
  # only the GNOME DESKTOP; ask for GDM with `displayManager = "gdm"`.
  config = lib.mkIf (cfg.enable && builtins.elem "gnome" cfg.types) {
    services.desktopManager.gnome.enable = true;
    # Delete core apps
    services.gnome.core-apps.enable = false;
    services.gnome.gnome-keyring.enable = true;
  };
}
