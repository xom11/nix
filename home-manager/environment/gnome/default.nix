{ lib, device, ... }:
{
  imports = lib.optionals (device == "desktop") [
    ./dconf.nix
    ./extensions.nix
  ];
}
