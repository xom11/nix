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
  # GDM da CHUYEN sang `dm-gdm.nix` (19/08/2026). Truoc day file nay bat ca
  # hai, nen "bo gnome" dong nghia "mat luon man dang nhap" -- mot rang buoc
  # khong ai co y tao ra. Gio muc nay chi con lo DESKTOP GNOME; muon GDM thi
  # dat `displayManager = "gdm"`, va hai thu do khong con dinh nhau.
  config = lib.mkIf (cfg.enable && builtins.elem "gnome" cfg.types) {
    services.desktopManager.gnome.enable = true;
    # Delete core apps
    services.gnome.core-apps.enable = false;
    services.gnome.gnome-keyring.enable = true;
  };
}
