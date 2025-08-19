{distro, ...}:
if distro == "ubuntu" then
  {
    imports = [
      ./pkgs
      ./programs
    ];
  }
else
  {}
