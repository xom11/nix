{distro, ...}:
if distro == "ubuntu" then
  {
    imports = [
      ./desktop
      ./gnome
      ./pwa
      ./desktop
    ];
  }
else if distro == "nixos" then
  {
    imports = [
      # ./desktop
      ./gnome
      # ./pwa
      ./desktop
    ];
  }
else
  {} 
