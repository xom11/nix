{ config, pkgs, lib, username, device, ... }:
let 
  hostname = "${device}_${username}";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
    wakeOnLan.enable = true;
  };

}