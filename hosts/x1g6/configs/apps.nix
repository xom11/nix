{pkgs, username, ...}:
{
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.tailscale.enable = true;
  services.openssh.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    fira-code
    fira-code-symbols
    meslo-lgs-nf
  ];
}