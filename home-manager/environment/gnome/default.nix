{ lib, device, pkgs, ... }:
{
  imports = [
  ] ++ lib.optionals (device == "x1g6") [
    ./dconf.nix
    ./extensions.nix
  ];
}