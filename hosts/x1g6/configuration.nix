{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
}