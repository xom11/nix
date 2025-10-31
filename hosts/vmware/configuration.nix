
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
  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
