{config, pkgs, ...}:
{
  home.packages = with pkgs; [
    tailscale
    openssh
  ];
  home.files.".ssh/authorized_keys".source = ./authorized_keys;

}