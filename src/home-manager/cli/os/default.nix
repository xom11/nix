{ lib, distro, ... }:

{
  imports = [
    (lib.mkIf (distro == "macos") ./macos)
    (lib.mkIf (distro == "nixos") ./nixos)
    (lib.mkIf (distro == "ubuntu") ./ubuntu)
  ];
}