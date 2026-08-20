{
  config,
  pkgs,
  username,
  mkModule,
  ...
}:
# Full-VM virtualisation. Unlike `virtualisation.docker`, which every NixOS host
# gets unconditionally, this is opt-in.
mkModule config ./. {
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # `pkgs.qemu` emulates foreign architectures too; _kvm carries only the
      # host's. Guests here match the host, so the rest is just disk.
      package = pkgs.qemu_kvm;

      # qemu runs as `qemu-libvirtd`, not root, so disk images must live where
      # that user can read them. An image in $HOME fails as a permission error,
      # not a config error.
      runAsRoot = false;

      # Not needed for a BIOS Linux guest. On anyway because it is the only
      # difference between running Linux and running Windows 11, and adding it
      # later means another rebuild.
      swtpm.enable = true;

      # Do NOT set `qemu.ovmf`: the submodule was removed from nixpkgs and now
      # only holds an assertion -- setting any field fails eval. OVMF images ship
      # with QEMU, so UEFI works with nothing declared.
    };

    # The default pairs `suspend` with `onBoot = "start"`, so a running guest is
    # managedsaved and comes back automatically "regardless of their autostart
    # settings" -- several GiB of RAM gone unannounced on a 7.6 GiB machine. With
    # "shutdown" there is nothing to restore, and only guests actually marked
    # autostart come up.
    onShutdown = "shutdown";

    # Default is 300: a guest that ignores ACPI holds up shutdown for 5 minutes.
    shutdownTimeout = 60;
  };

  # libvirtd puts `virsh` on PATH but not virt-install, which nixpkgs only ships
  # inside virt-manager -- GUI included, no way around it.
  #
  # cloud-utils provides `cloud-localds`, which builds the cloud-init seed ISO so
  # a guest picks up its SSH key on first boot without console interaction.
  environment.systemPackages = [
    pkgs.virt-manager
    pkgs.cloud-utils
  ];

  users.users.${username}.extraGroups = ["libvirtd"];
}
