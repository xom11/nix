# The whole disk for NixOS; dual-boot Windows was dropped after two failed
# installs.
#
#   ESP    1G      EF00   /boot
#   root   ~459.9G ext4   /       <- everything but the last 16G
#   swap   16G     8200           <- >= RAM, so hibernate works
#
# The 1G ESP is inherited from the Windows era and not worth shrinking, since that
# means recreating the first partition.
#
# `end = "-16G"` on root plus `size = "100%"` on swap: disko pushes the `100%`
# partition last, so the physical order comes out ESP -> root -> swap with no
# sector arithmetic.
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
