{input, config, pkgs, lib, ... }:
{
  virtualisation.docker.enable = true;
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  virtualisation.libvirtd.enable = true;

}