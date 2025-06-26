{ pkgs, ... }:
{
  services.redis.enable = true;
  services.tailscale.enable = true;
}