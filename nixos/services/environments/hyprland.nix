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

    # Phan xu portal, thu nixpkgs KHONG lam ho o day.
    #
    # `programs.sway` cua nixpkgs ship san /etc/xdg/xdg-desktop-portal/
    # sway-portals.conf (ScreenCast=wlr, Screenshot=wlr, default=gtk).
    # `programs.hyprland` KHONG ship gi tuong duong -- do tren rog 14/08/2026.
    # Ma ca `hyprland.portal` lan `wlr.portal` deu khai UseIn=...;Hyprland;...
    # nen phien Hyprland khong co ai phan xu hai backend.
    #
    # Chua do duoc no chon nham THAT (muon thay dong "Choosing ... for
    # interface ..." thi phai co mot phien Hyprland dang chay). Nhung dua vao
    # thu tu mac dinh la dua vao may rui; khoi nay bien no thanh xac dinh.
    #
    # Trieu chung neu thieu: KHONG co gi do luc rebuild, chi lo ra khi chia se
    # man hinh hoac chup anh man hinh vo cuc backend sai.
    xdg.portal.config.hyprland = {
      default = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
      "org.freedesktop.impl.portal.Screenshot" = "hyprland";
    };
  };
}
