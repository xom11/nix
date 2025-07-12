{ config, pkgs, lib, username, ... }:
let 
  hostname = "macmini-kln";
in
{
 
  imports = [
    ../../MAC/base
    ../../MAC/brew
    ../../MAC/system
    ../../MAC/network
  ];

}