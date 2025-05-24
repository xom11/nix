{config, pkgs, ...}:
{
  home.packages = with pkgs; [
    tailscale
    openssh
  ];
  programs.ssh = {
    enable = true;
    startAgent = true;

  };
  home.file.".ssh/authorized_keys".source = ./authorized_keys;
  # home.file.".ssh/id_ed25519".mode = "0600";
  # home.file.".ssh/id_ed25519.pub".mode = "0644";
  home.file.".ssh".mode = "0700";
}