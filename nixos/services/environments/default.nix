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
      # "i3wm" was removed (ATTIC.md) when X11 was dropped for sway.
      #
      # The old note here claimed `gnome` was the default because it was the only
      # single value that worked on its own, since it pulled in GDM. That stopped
      # being true when `displayManager` was split out: the two axes are now
      # INDEPENDENT -- `types` picks which SESSIONS exist, `displayManager` picks
      # the login screen -- so `types = ["sway"]` alone is valid.
      default = ["gnome"];
      description = ''
        Danh sach desktop environment / compositor se cai. Moi phan tu la mot
        session rieng o man dang nhap. Truoc day day la `type` mot gia tri --
        doi ten CO Y de host nao con cu phap cu thi loi eval to, khong im lang.
      '';
    };
    displayManager = lib.mkOption {
      type = lib.types.enum ["gdm" "regreet" "none"];
      # Defaults to "gdm" so existing hosts kept their behaviour when this axis
      # was split out.
      default = "gdm";
      description = ''
        Ai ve man hinh dang nhap. DOC LAP voi `types`: mot display manager liet
        ke MOI session trong `types`, khong rang buoc gi vao session cu the.

        - "gdm"     -- GNOME Display Manager. Keo theo mot phan stack GNOME
                       ngay ca khi khong bat `types = ["gnome"]`.
        - "regreet" -- greetd + ReGreet. greetd la daemon KHONG co giao dien
                       (chi lo PAM + khoi dong session), ReGreet la phan ve
                       giao dien, chay trong `cage`. Nhe hon GDM nhieu.
        - "none"    -- khong co man dang nhap do hoa nao. May boot thang vao
                       console text; dang nhap roi tu go `sway` / `Hyprland` /
                       `niri-session`. KHONG phai loi -- chi la khong ai ve
                       man dang nhap ra.
      '';
    };
  };
}
