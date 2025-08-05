{...}:
{
  imports = [
      # /etc/nixos/configuration.nix
      /etc/nixos/hardware-configuration.nix
      ../../src/nixos
    ];
  # lsblk -f
  boot.kernelParams = ["resume_offset=96571392"];
  # sudo filefrag -v /var/lib/swapfile | head
  boot.resumeDevice = "/dev/disk/by-uuid/11811a7d-9865-468e-afc6-4148f4a03535";
}