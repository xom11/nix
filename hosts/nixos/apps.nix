{input, config, pkgs, lib, ... }:
{
  virtualisation.docker.enable = true;
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;

}