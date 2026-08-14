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
      type = "gnome";
    };
    kanata.enable = true;
    # Host duy nhat bat libvirtd: no la may co VT-x va con du dia. Nho vay
    # x1g6/vm khong phai keo theo virt-manager va closure QEMU.
    libvirtd.enable = true;
  };
}
