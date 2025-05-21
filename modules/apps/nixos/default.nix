{pkgs, ...}:
{
  imports = [
    ../shared
    ./nixpkgs.nix
    ./desktopFile.nix
    ./flatpak.nix
  ];
}