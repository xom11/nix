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
  ];

  # Dual-boot: Windows ghi RTC theo gio dia phuong, Linux mac dinh doc RTC la
  # UTC. Khong co dong nay thi moi lan doi HDH dong ho lech dung 7 tieng
  # (Asia/Ho_Chi_Minh, dat trong nixos/base).
  #
  # Khong can khai bao gi de thay Windows trong menu boot: systemd-boot tu quet
  # ESP va tu them muc khi thay `EFI/Microsoft/Boot/bootmgfw.efi`.
  time.hardwareClockInLocalTime = true;

  # Ghi de mkDefault "24.11" cua nixos/base. May nay cai moi 14/08/2026 tren
  # 26.05, khong co du lieu cu nao can giu hanh vi cu.
  system.stateVersion = "26.05";

  modules.nixos.services = {
    environments = {
      enable = true;
      type = "gnome";
    };
    kanata.enable = true;
  };
}
