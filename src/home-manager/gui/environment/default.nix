{distro, ...}:
if distro == "ubuntu" then
  {
    imports = [
      ./gnome
    ];
  }
else if distro == "nixos" then
  {
    imports = [
      # ./desktop
      ./gnome
      # ./pwa
    ];
  }
else
  {} 
