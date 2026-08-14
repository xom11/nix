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
      type = lib.types.listOf (lib.types.enum ["i3wm" "gnome" "kde" "sway" "hyprland"]);
      default = ["i3wm"];
      description = ''
        Danh sach desktop environment / compositor se cai. Moi phan tu la mot
        session rieng o man dang nhap. Truoc day day la `type` mot gia tri --
        doi ten CO Y de host nao con cu phap cu thi loi eval to, khong im lang.
      '';
    };
  };
}
