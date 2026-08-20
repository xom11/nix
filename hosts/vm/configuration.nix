
{ pkgs, ... }:
{
  imports = [
    ../../nixos
    ./disko.nix
    ./hardware.nix
  ];
  modules.nixos = {
    services = {
      environments.enable = true;
      environments.types = ["gnome"];
      kanata.enable = true;
    };
  };

  # `virtualisation.vmware.guest` creates a fuse .mount unit for vmblock, and
  # `mount -t fuse` needs util-linux's `mount.fuse` helper, which is not in the
  # module's closure. Without it the mount fails with "wrong fs type" and
  # switch-to-configuration returns 4, so EVERY rebuild reports failure after
  # applying successfully. Calling the binary directly works, which is what
  # pinpoints the helper. `mount` looks it up in /run/current-system/sw/bin --
  # a hand-passed PATH is ignored, since /run/wrappers/bin/mount is setuid and
  # scrubs the environment.
  environment.systemPackages = [ pkgs.fuse ];
  # The VMware NAT DNS forwarder does not answer, though routing itself is fine.
  # The consequence is indirect: `gitclonenix` clones GitHub AT ACTIVATION, so a
  # DNS failure kills home-manager-<user>.service with exit 128, no dotfiles are
  # written, and i3 boots into its first-run wizard.
  #
  # Must be insertNameservers, NOT networking.nameservers: the latter still lets
  # NetworkManager put the DHCP server FIRST, and the resolver tries in order --
  # it stalls on the broken one and gives up before reaching these. The symptom
  # is a resolv.conf that looks right while `getent hosts` returns nothing.
  networking.networkmanager.insertNameservers = [ "1.1.1.1" "8.8.8.8" ];

  # VMware Guest Tools
  virtualisation.vmware.guest.enable = true;
}
