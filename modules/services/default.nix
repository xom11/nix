{...}:
{
  services.ssh-agent.enable = true;
  services.podman = {
    enable = true;
  };
  services.preload.enable = true;
}