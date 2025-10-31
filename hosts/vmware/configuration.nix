
{ ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules = {
    services = {
      desktop-environment.enable = true;
    };
  };
  # Bug: vmware DNS
  # Install VMware Tools
  virtualisation.vmware.guest.enable = true;
}
