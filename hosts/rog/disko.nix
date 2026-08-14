# Dual-boot NixOS + Windows tren mot o NVMe 476,9 GiB.
#
#   ESP    1G      EF00   /boot    <- DUNG CHUNG cho ca systemd-boot lan
#                                     Windows Boot Manager
#   root   222G    ext4   /
#   swap   16G     8200            <- >= RAM (8G) nen hibernate duoc
#   ~238G con lai DE TRONG          <- trinh cai Windows tu tao MSR + NTFS
#                                     + recovery trong khoang nay
#
# Hai cho khac x1g6, ca hai deu do dual-boot:
#
# - ESP 1G thay vi 512M. Mot ESP duy nhat phai chua ca cac generation cua
#   systemd-boot LAN `EFI/Microsoft/Boot/bootmgfw.efi`. 512M du cho NixOS mot
#   minh, chat khi them Windows.
# - `size` tuyet doi cho `root` thay vi `end = "-16G"`. x1g6 an het o nen tinh
#   nguoc tu duoi len duoc; o day phai chua lai mot khoang trong o CUOI o cho
#   Windows, nen phai neu kich thuoc thang.
#
# Thu tu vat ly = thu tu alphabet cua ten partition (ESP < root < swap), vi
# khong cai nao dung `size = "100%"` — thu do bi disko day xuong cuoi cung.
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
                # Windows CHI chap nhan ESP la FAT32. mkfs.vfat thuong tu chon
                # FAT32 o kich thuoc nay, nhung ep thang thi khong phai dat cuoc
                # vao heuristic cua dosfstools.
                extraArgs = [ "-F" "32" ];
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "222G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "16G";
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
