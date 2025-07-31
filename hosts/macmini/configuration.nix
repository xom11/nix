{ config, pkgs, lib, username, ... }:
let 
  hostname = "macmini-kln";
in
{
 
  imports = [
    ../../MACOS
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}