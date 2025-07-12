{ config, pkgs, lib, username, ... }:
let 
  hostname = "macair-qphus";
in
{
 
  imports = [
    ../../MACOS/base
    ../../MACOS/system
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}