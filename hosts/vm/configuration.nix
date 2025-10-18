
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
}
