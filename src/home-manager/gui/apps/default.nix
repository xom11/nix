{distro, ...}:
if distro == "nixos" then
  {
    imports = [
      ./pkgs
      ./programs
    ];
  }
else
  {}
