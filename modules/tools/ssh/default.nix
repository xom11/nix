{config, pkgs, ...}:
{
  home.packages = with pkgs; [
    tailscale
    openssh
  ];
  # programs.ssh = {
  #   enable = true;

  # };
  home.file.".ssh/authorized_keys".source = ./authorized_keys;
}