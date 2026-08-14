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
  # LUU Y: module nay chi cai session .desktop. Thu liet ke no o man dang nhap la
  # GDM, va GDM do gnome.nix bat. Host nao bat "sway" ma khong bat
  # "gnome" se co session nhung khong co display manager nao hien no ra.
  config = lib.mkIf (cfg.enable && builtins.elem "sway" cfg.types) {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };
}
