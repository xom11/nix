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
  # `programs.sway` lo het phan kho: cai session .desktop vao
  # /share/wayland-sessions (GDM doc tu do), keo xdg-desktop-portal-wlr, dbus,
  # polkit. Khong can khai tay gi them.
  config = lib.mkIf (cfg.enable && builtins.elem "sway" cfg.types) {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
