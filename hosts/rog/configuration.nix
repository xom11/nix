{ nixos-hardware, ... }:
{
  # nixos-hardware khong co profile rieng cho G531GT — chi co cac module chung.
  # `common-cpu-intel` keo theo ca `common-gpu-intel` (UHD 630 cua i5-9300H).
  imports = [
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    ../../nixos
    ./disko.nix
    ./hardware.nix
    ./nvidia.nix
    ./touchpad.nix
  ];

  # `time.hardwareClockInLocalTime` da BO cung luc voi Windows (14/08/2026).
  # No chi ton tai de hai HDH khong lech 7 tieng; may nay gio chi con NixOS,
  # va de lai thi RTC bi ghi theo gio dia phuong ma khong con ai can dieu do.

  # Ghi de mkDefault "24.11" cua nixos/base. May nay cai moi 14/08/2026 tren
  # 26.05, khong co du lieu cu nao can giu hanh vi cu.
  system.stateVersion = "26.05";

  # Chromium/Electron chay Wayland GOC thay vi XWayland. Day khong phai tinh
  # chinh hieu nang — no la thu sua phim tat beckon cho PWA cua Brave.
  #
  # Do 16/08/2026 tren chinh may nay, cung mot PWA, hai che do:
  #
  #   XWayland      class = "Brave-browser"                     <- giong het
  #                 WM_CLASS = ("crx_<hash>", "Brave-browser")     trinh duyet
  #   Wayland goc   class = "brave-<app-id>-Default"
  #
  # Duoi XWayland moi cua so PWA deu mang class y het trinh duyet chinh, nen
  # beckon khong nhan ra app dang chay va MO THEM MOT BAN SAO moi lan bam
  # phim tat (do: bam 2 lan -> 2 cua so, ca Claude lan YouTube). Nua instance
  # cua WM_CLASS thi dung, nhung Hyprland khong he lo no — dump ca 32 truong
  # cua `hyprctl clients -j`, khong truong nao chua "crx_".
  #
  # Duoi Wayland goc, class chinh la STEM ten file .desktop, thu ma
  # `desktop::target_classes` cua beckon da dua vao tap target tu dau. Nen van
  # de bien mat chu khong phai duoc va. Do lai sau khi doi: Launched -> 3,
  # Focused -> 3 (khong nhan doi), dung cho ca hai PWA.
  #
  # An toan tren may nay vi hai le, ca hai deu kiem chu khong doan:
  #   - wrapper cua nixpkgs khoa KEP: ${NIXOS_OZONE_WL:+${WAYLAND_DISPLAY:+...}}
  #     nen khong co WAYLAND_DISPLAY thi khong them co nao;
  #   - rog khong co phien X11 nao ca — /run/current-system/sw/share/xsessions
  #     rong, chi co bon wayland-session (hyprland, hyprland-uwsm, niri, sway).
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  modules.nixos.services = {
    environments = {
      enable = true;
      # GNOME DA BO HAN 19/08/2026, cung luc doi GDM -> greetd + ReGreet.
      #
      # Truoc do GNOME o lai lam luoi an toan (cau hinh sway/hyprland/niri
      # hong thi van co desktop de vao). Bo di la CO Y chon: loi thoat con
      # lai la TTY va SSH — khong co desktop, nhung ve mat cuu ho thi TTY con
      # chac hon GDM, vi no khong phu thuoc GPU lan compositor nao ca.
      #
      # LUU Y khi doc lai: bo "gnome" khoi day KHONG con dong nghia voi mat
      # man dang nhap. Hai truc da tach (xem environments/default.nix) —
      # `types` chon co session nao, `displayManager` chon ai ve man dang
      # nhap. Truoc 19/08/2026 chung dinh nhau va bo "gnome" la mat ca hai.
      #
      # "niri" them 14/08/2026 de THU (scrollable-tiling). Xem
      # nixos/services/environments/niri.nix: module nixpkgs cua no CO Y dat
      # `defaultSession = "niri"`, va file do phai chan lai. Ly do cu la
      # "khong thi autoLogin dua thang vao niri"; autoLogin nay da tat (xem
      # dm-regreet.nix) nen ly do do het hieu luc, nhung cai chan van nen giu:
      # `defaultSession` con quyet dinh muc duoc chon san o ReGreet.
      types = ["sway" "hyprland" "niri"];

      # greetd (daemon, khong co giao dien) + ReGreet (phan ve giao dien,
      # chay trong cage). Xem dm-regreet.nix.
      displayManager = "regreet";
    };
    # dotbrave KHONG con o tang nao cua rebuild nua (16/08/2026) -- ATTIC.md,
    # `attic/dotbrave-modules-2026-08-16`. brave.toml van trong repo va binary
    # van trong PATH (home.nix), ap bang tay.
    kanata.enable = true;
    # Tang he thong cua bo go: nap udev rule + unit fcitx5-lotus-server@.
    # Thieu no thi bon che do Uinput cua lotus (thu KHONG gach chan trong kitty)
    # khong the chay. Addon fcitx5 van do home-manager/environments/i18n cai.
    # Di kem: `linux-dev-names-exclude` trong configs/kanata/defcfg.kbd, vi
    # kanata mac dinh se grab luon thiet bi ao cua lotus.
    fcitx5-lotus.enable = true;
    # Host duy nhat bat libvirtd: no la may co VT-x va con du dia. Nho vay
    # vm khong phai keo theo virt-manager va closure QEMU.
    libvirtd.enable = true;
  };
}
