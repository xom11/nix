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

  modules.nixos.services = {
    environments = {
      enable = true;
      # GNOME o lai lam luoi an toan: cau hinh sway/hyprland/niri hong cung
      # khong khoa duoc nguoi dung khoi may. Bon muc nay = bon session o GDM.
      #
      # "niri" them 14/08/2026 de THU (scrollable-tiling). Xem
      # nixos/services/environments/niri.nix: module nixpkgs cua no CO Y dat
      # `defaultSession = "niri"`, va file do phai chan lai — neu khong,
      # autoLogin cua nixos/base se dua may vao thang niri va GNOME het lam
      # luoi an toan.
      types = ["gnome" "sway" "hyprland" "niri"];
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
    # x1g6/vm khong phai keo theo virt-manager va closure QEMU.
    libvirtd.enable = true;
  };
}
