{pkgs, ...}:
{
  virtualisation.docker.enable = true;
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  # virtualisation.libvirtd.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;
programs.virt-manager.enable = true;

users.groups.libvirtd.members = ["kln"];

virtualisation.libvirtd.enable = true;

virtualisation.spiceUSBRedirection.enable = true;
}