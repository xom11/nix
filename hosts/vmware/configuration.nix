
{ ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      desktop-environment.enable = true;
    };
  };
  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
