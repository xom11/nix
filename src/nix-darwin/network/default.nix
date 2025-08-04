{ config, pkgs, lib, username, device, ... }:
let 
  hostname = "${device}-${username}";
in
{
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
    wakeOnLan.enable = true;
  };

}