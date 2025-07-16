{ config, lib, pkgs, ... }:

{
  imports = [
    ../../LINUX/base
    ../../LINUX/services
  ];
  environment.etc."environment.d/system-manager-path.conf".text= ''
    PATH="/run/system-manager/sw/bin/:$PATH"
  '';
}