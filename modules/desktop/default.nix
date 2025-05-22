{pkgs, ...}:
{
  imports = [
    ./nixpkgs.nix
    ./desktopFile.nix
    ./flatpak.nix
  ];
}