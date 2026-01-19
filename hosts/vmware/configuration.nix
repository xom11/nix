
{ ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      environment.enable = true;
    };
  };
  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
