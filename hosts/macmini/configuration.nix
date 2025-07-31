{ config, pkgs, lib, username, ... }:
let 
  hostname = "macmini-kln";
in
{
 
  imports = [
    ../../src/nix-darwin
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}