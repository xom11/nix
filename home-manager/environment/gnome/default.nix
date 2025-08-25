{ lib, device, pkgs, ... }:
{
  imports = [
  ] ++ lib.optionals (device == "x1g6" || device == "desktop") [
    ./dconf.nix
    ./extensions.nix
  ];
}