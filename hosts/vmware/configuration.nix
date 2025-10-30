
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
  networking.nameservers = [
    "8.8.8.8"    # Google Public DNS
    "1.1.1.1"    # Cloudflare DNS
  ];
}
