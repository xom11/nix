{ config, pkgs, lib, username, ... }:
let 
  hostname = "macair-qphus";
in
{
 
  imports = [
    ../../MAC/base
    ../../MAC/system
  ];
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };

}