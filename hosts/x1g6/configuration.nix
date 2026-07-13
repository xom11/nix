{ nixos-hardware, ... }:
{
  imports = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos.services = {
    environments = {
      enable = true;
      type = "i3wm";
    };
    # kanata.enable = true;
    keyd.enable = true;
  };
}
