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
  # Tuong tu sway.nix: option cua nixpkgs tu cai session .desktop va keo
  # xdg-desktop-portal-hyprland. Binary hyprland den tu day, nen module
  # home-manager ben kia chi lo config.
  # LUU Y: module nay chi cai session .desktop. Thu liet ke no o man dang nhap la
  # GDM, va GDM do gnome.nix bat. Host nao bat "hyprland" ma khong bat
  # "gnome" se co session nhung khong co display manager nao hien no ra.
  config = lib.mkIf (cfg.enable && builtins.elem "hyprland" cfg.types) {
    programs.hyprland.enable = true;
  };
}
