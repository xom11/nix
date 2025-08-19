{lib, distro, ...}:
lib.mkIf (distro == "macos") {
  imports = [
    ./macos
  ];
} 
lib.mkIf (distro == "nixos") {
  imports = [
    ./nixos
  ];
} 
lib.mkIf (distro == "ubuntu") {
  imports = [
    ./ubuntu
  ];
} 