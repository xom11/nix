
{ ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      environments.enable = true;
      # kanata.enable = true;
    };
  };
  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
