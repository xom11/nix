{...}:
{
  services.ssh-agent.enable = true;
  home.packages = with pkgs; [
    shadow
    podman
  ];
  services.podman = {
    enable = true;
  };
}