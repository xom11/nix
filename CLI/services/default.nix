{pkgs, ...}:
{
  # services.ssh-agent.enable = true;
  services.podman = {
    enable = true;
    extraPackages = with pkgs; [ shadow ];
  };
}