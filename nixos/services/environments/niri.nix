{
  config,
  lib,
  pkgs,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # Nhu sway.nix/hyprland.nix: `programs.niri` cua nixpkgs cai session .desktop
  # vao /share/wayland-sessions, keo portal, dbus, polkit. Module home-manager
  # ben kia chi lo config.kdl.
  # LUU Y: module nay chi cai session .desktop. Thu liet ke no o man dang nhap la
  # GDM, va GDM do gnome.nix bat.
  config = lib.mkIf (cfg.enable && builtins.elem "niri" cfg.types) {
    programs.niri = {
      enable = true;

      # Mac dinh cua nixpkgs la `true`, va no keo `pkgs.nautilus` vao
      # services.dbus.packages de FileChooser cua xdg-desktop-portal-gnome chay
      # dung. rog CO Y tat `services.gnome.core-apps` (xem gnome.nix), nen de
      # mac dinh la nautilus quay lai bang cua sau. Tat di thi module tu chuyen
      # org.freedesktop.impl.portal.FileChooser sang "gtk".
      useNautilus = false;
    };

    # ================= MIN, phai chan bang tay =================
    # `programs.niri` cua nixpkgs dat:
    #     services.displayManager.defaultSession = lib.mkDefault "niri";
    # (co y, de setup chi-co-niri khong bi GDM 50 roi vao vong lap dang nhap).
    #
    # Tren rog dieu do PHA hai thu cung luc, va ca hai deu im lang:
    #   1. gdm.nix chay o preStart `set-session <autologinSession>` CHI KHI
    #      defaultSession != null -- kem comment cua chinh nixpkgs: "basically
    #      ignore session history". Nghia la moi lan GDM khoi dong, lua chon
    #      session cua nguoi dung trong AccountsService bi ghi de ve niri.
    #   2. nixos/base bat `services.displayManager.autoLogin`, ma autoLogin lay
    #      dung defaultSession lam session. Cong lai: may tu dang nhap thang vao
    #      niri, va GNOME het lam luoi an toan.
    #
    # Dat lai `null` (gan thuong, uu tien 100, thang mkDefault 1000) tra ve dung
    # hanh vi truoc khi bat niri: GDM khong dung toi AccountsService, nen cach
    # doi session bang `SetSession` qua D-Bus van con tac dung.
    #
    # Host nao sau nay muon niri lam session mac dinh thi dat lai o host do,
    # dung go dong nay.
    services.displayManager.defaultSession = null;

    # niri >= 25.08 tu tao socket X11, tu dat $DISPLAY va tu spawn
    # xwayland-satellite khi co client X11 goi den (tu restart neu no chet) --
    # nen KHONG can khai `xwayland enable` nhu hypr.d, chi can binary co trong
    # PATH. Dat o systemPackages chu khong phai home.packages: PATH ma niri
    # dung la PATH `niri-session` nap vao systemd user manager.
    #
    # Can no vi cung ly do da ghi o hypr.d: Zalo va vai app Electron cu la
    # X11-only. Thieu no thi chung khong mo duoc va khong bao gi.
    environment.systemPackages = [pkgs.xwayland-satellite];
  };
}
