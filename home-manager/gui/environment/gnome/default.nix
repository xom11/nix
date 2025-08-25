{lib, devices, pkgs, ...}:
lib.mkIf (pkgs.stdenv.isLinux && device != "server") 
{
    imports = [
        ./extensions.nix
        ./dconf.nix
    ];
}