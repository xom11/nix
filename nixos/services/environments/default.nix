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
      # cho.
      #
      # GHI CHU CU DA SAI, sua 19/08/2026: cho nay tung viet "default la
      # `gnome` vi no la gia tri MOT phan tu duy nhat tu no dung duoc: no keo
      # theo GDM". Dieu do dung cho toi khi `displayManager` ben duoi ra doi.
      # Gio hai truc DOC LAP: `types` chon co nhung SESSION nao, con
      # `displayManager` chon AI VE MAN DANG NHAP. `types = ["sway"]` mot minh
      # la hop le, mien la displayManager khac "none".
      default = ["gnome"];
      description = ''
        Danh sach desktop environment / compositor se cai. Moi phan tu la mot
        session rieng o man dang nhap. Truoc day day la `type` mot gia tri --
        doi ten CO Y de host nao con cu phap cu thi loi eval to, khong im lang.
      '';
    };
    displayManager = lib.mkOption {
      type = lib.types.enum ["gdm" "regreet" "none"];
      # Mac dinh "gdm" de host cu khong doi hanh vi khi truc nay duoc tach ra
      # (luc do chi co vm, va no dua han vao GDM di kem `types = ["gnome"]`).
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
