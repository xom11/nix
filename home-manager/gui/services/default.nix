{lib, pkgs, ...}:
lib.mkIf pkgs.stdenv.isLinux
{
services.picom.enable = true;
}