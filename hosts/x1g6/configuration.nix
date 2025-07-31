{...}:
{
  imports = [
      # /etc/nixos/configuration.nix
      /etc/nixos/hardware-configuration.nix
      ./hibernate.nix
      ../../src/nixos
    ];
}