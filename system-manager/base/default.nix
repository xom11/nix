{
  config,
  pkgs,
  lib,
  system,
  ...
}: {
  nixpkgs.hostPlatform = system;
  system-manager.allowAnyDistro = true;
  # No preActivationAssertions: the old setup_init ran `usermod -aG sudo $USER`
  # from a root context, so $USER was root -- it added root to the sudo group
  # and never touched the real user. hosts/*/install already grants sudo via
  # /etc/sudoers.d/$USER before a switch can run at all.
  environment.etc."sudoers.d/nix-path" = {
    text = ''
      Defaults secure_path="/run/system-manager/sw/bin:/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
    '';
  };
  environment.systemPackages = with pkgs; [
    cowsay
  ];
}
