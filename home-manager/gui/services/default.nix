{lib, pkgs, device, ...}:
lib.mkIf (pkgs.stdenv.isLinux && device != "server") ( 
{
services.picom.enable = true;
}