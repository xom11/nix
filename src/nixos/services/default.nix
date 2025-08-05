{pkgs, username, ...}:
{
  imports = [
    ./hibernate.nix
    ./keyd.nix
  ];
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.preload.enable = true;
  services.flatpak.enable = true;

  services.pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
