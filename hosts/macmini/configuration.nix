{ config, pkgs, lib, username, ... }:
let 
  hostname = "macmini-kln";
in
{
 
  imports = [
    ../../MACOS/base
    ../../MACOS/brew
    ../../MACOS/system
    ../../MACOS/power
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}