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
  # Tach ra khoi gnome.nix ngay 19/08/2026. Xem ghi chu o do: GDM va desktop
  # GNOME tung bi gop lam mot, khien "bo GNOME" keo theo "mat man dang nhap".
  #
  # GDM van la lua chon nang nhat trong ba: no la mot ung dung GNOME nen keo
  # theo mutter va mot phan stack GNOME NGAY CA khi `types` khong co "gnome".
  # Doi lai no la thu duoc thu nghiem nhieu nhat va xu ly nguoi dung/phien
  # day du nhat.
  config = lib.mkIf (cfg.enable && cfg.displayManager == "gdm") {
    services.displayManager.gdm.enable = true;
  };
}
