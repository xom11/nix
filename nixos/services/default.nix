{pkgs, username, ...}:
{
  imports = [
    # ./hibernate.nix
    ./keyd.nix
    ./i3wm.nix
    # ./ibus.nix
  ];
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.preload.enable = true;
  # services.flatpak.enable = true;

}
