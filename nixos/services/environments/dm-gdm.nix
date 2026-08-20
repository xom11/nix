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
  # Split out of gnome.nix, where GDM and the GNOME desktop were fused so that
  # dropping GNOME also dropped the login screen.
  #
  # Still the heaviest of the three: GDM is a GNOME application, so it pulls in
  # mutter and part of the GNOME stack EVEN when `types` excludes "gnome". In
  # exchange it is the best-tested and handles users and sessions most fully.
  config = lib.mkIf (cfg.enable && cfg.displayManager == "gdm") {
    services.displayManager.gdm.enable = true;
  };
}
