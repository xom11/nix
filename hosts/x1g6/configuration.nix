{input, config, pkgs, lib, username, ... }:
let
  hostname = "x1g6-kln";
in
{
  imports = [
      # /etc/nixos/configuration.nix
      /etc/nixos/hardware-configuration.nix
      ./hibernate.nix

      ../../NIXOS/base
      ../../NIXOS/services
    ];


  networking.hostName = hostname;

}