{ config, pkgs, lib, username, ... }:
let 
  hostname = "macbook-${username}";
in
{
 
  imports = [
    ../../MACOS/base
    # ../../MACOS/system
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}