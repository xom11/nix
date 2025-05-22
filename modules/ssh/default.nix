{config, pkgs, ...}:
{
  # home.packages = with pkgs; [
  #   tailscale
  #   openssh
  # ];
  services.tailscale ={
    enable = true;
  };
  programs.openssh = {
    enable = true;
    passwordAuthentication = false;
    publicKeyAuthentication = true;
  };
}