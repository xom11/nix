{inputs, ...}:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];

}