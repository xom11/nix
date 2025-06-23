{pkgs, ...}:
{
  virtualisation.docker.enable = true;
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  virtualisation.libvirtd.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;
   virtualisation.virtualbox.host.enable = true;
   users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
}