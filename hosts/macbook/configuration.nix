{ config, pkgs, lib, username, ... }:
let 
  hostname = "macbook-${username}";
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