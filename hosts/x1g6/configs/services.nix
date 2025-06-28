{pkgs, username, ...}:
{
  virtualisation.docker.enable = true;
  users.users.${username}.extraGroups = [ "docker" ];

  services.tailscale.enable = true;
  services.openssh.enable = true;

  # i18n.inputMethod = {
  #   enable = true;
  #   type = "ibus";
  #   ibus.engines = with pkgs.ibus-engines; [bamboo];
  # };

}