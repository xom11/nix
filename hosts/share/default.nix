{pkgs, lib, config, ...}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    fira-code
    fira-code-symbols
    meslo-lgs-nf
  ];
  services.tailscale.enable = true;
}