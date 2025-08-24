{lib, pkgs, ...}:
lib.mkIf pkgs.stdenv.isLinux
{
  imports = [
    ./gnome-extensions.nix
    ./gnome-settings.nix
    ./gnome-pkgs.nix
  ];
}