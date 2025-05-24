{config, pkgs, ...}:
{
  home.packages = with pkgs; [
    tailscale
    openssh
  ];
  home.file.".ssh/authorized_keys".source = ./authorized_keys;
  home.file.".ssh/config".source = ./config;



}