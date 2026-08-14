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
      types = ["i3wm"];
    };
    # Truoc day la keyd (go 10/08/2026). kanata dung CHUNG configs/kanata voi
    # macmini, airm3, vm va a14-win -- mot engine, mot bo layout, thay vi mot
    # engine rieng chi host nay dung.
    kanata.enable = true;
  };
}
