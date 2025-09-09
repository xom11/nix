{nixos-hardware, ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];

}