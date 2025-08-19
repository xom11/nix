{distro, lib, ...}:
lib.mkIf (distro == "nixos")
{
  imports = [
    ./programs
    ./pkgs
  ];
}