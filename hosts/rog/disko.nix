# Toan bo o cho NixOS. Dual-boot Windows da BO han 14/08/2026 sau hai lan cai
# that bai (lan dau Windows Update pha boot, lan hai trinh cai khong nhin thay
# o khi boot tu USB) -- chu may quyet dinh khong dung Windows tren may nay nua.
#
#   ESP    1G      EF00   /boot
#   root   ~459.9G ext4   /        <- an het o, tru 16G cuoi
#   swap   16G     8200            <- >= RAM (8G) nen hibernate duoc
#
# Gio giong het hosts/x1g6/disko.nix, chi khac ESP 1G thay vi 512M: kich thuoc
# do la di san tu thoi con chia cho Windows Boot Manager, va khong dang thu hep
# lai vi phai xoa/tao lai phan vung dau o.
#
# `end = "-16G"` cho root + `size = "100%"` cho swap: disko day phan vung
# `100%` xuong cuoi cung, nen thu tu vat ly ra dung ESP -> root -> swap ma
# khong phai tinh sector nao.
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              end = "-16G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hibernation from this device
              };
            };
          };
        };
      };
    };
  };
}
