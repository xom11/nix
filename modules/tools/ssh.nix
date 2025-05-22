{config, pkgs...}:
{
  services.tailscale ={
    enable = true;
  };
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    publicKeyAuthentication = true;
  };
}