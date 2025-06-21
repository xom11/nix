{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

  ]; 
  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    fira-code
    fira-code-symbols
    meslo-lgs-nf
  ];
  services.redis.enable = true;
  services.tailscale.enable = true;
}