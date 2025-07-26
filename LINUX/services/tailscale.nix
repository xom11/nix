
{ config, lib, pkgs, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      tailscale
    ];
  };
  systemd.services = {
    tailscale = {
      enable = true;
      description = "Tailscale node agent";
      documentation = [ "https://tailscale.com/kb/" ];
      wantedBy = [ "multi-user.target" ];
      after = [ "network-pre.target" "NetworkManager.service" "systemd-resolved.service" ];
      wants = [ "network-pre.target" ];
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.tailscale}/bin/tailscaled --port 41641 ";
        ExecStartPost = "${pkgs.tailscale}/bin/tailscaled --cleanup";
        Restart = "on-failure";
      };
    };
  };
}
