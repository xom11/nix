{...}:
{
  services.ssh-agent.enable = true;
  services.podman = {
    enable = true;
  };
  services.copyq.enable = true;
}