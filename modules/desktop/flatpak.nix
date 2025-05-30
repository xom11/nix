{ config, pkgs, lib, ... }:
{
  services.flatpak.packages = [
    { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
    { appId = "com.sindresorhus.Caprine"; origin = "flathub"; }
  ];
}