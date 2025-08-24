{lib, ...}:
lib.mkIf lib.hm.isLinux
{
services.picom.enable = true;
}