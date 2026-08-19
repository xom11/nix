{
  config,
  lib,
  getRelPath,
  ...
}: let
  inherit (builtins) filter map toString;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
in {
  imports = filter (hasSuffix ".nix") (
    map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
  );
  options = lib.setAttrByPath pathList {
    enable = lib.mkEnableOption "Enable desktop environment services";
    types = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["gnome" "kde" "sway" "hyprland" "niri"]);
      # "i3wm" da bi go 19/08/2026 (ATTIC.md) -- chu may bo han X11, sway thay
      # cho. Default doi sang "gnome" vi day la gia tri MOT phan tu duy nhat tu
      # no dung duoc: no keo theo GDM. Bat "sway"/"hyprland"/"niri" mot minh thi
      # co session .desktop nhung khong display manager nao hien no ra.
      default = ["gnome"];
      description = ''
        Danh sach desktop environment / compositor se cai. Moi phan tu la mot
        session rieng o man dang nhap. Truoc day day la `type` mot gia tri --
        doi ten CO Y de host nao con cu phap cu thi loi eval to, khong im lang.
      '';
    };
  };
}
