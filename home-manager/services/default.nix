{ pkgs, lib, device, ... }:

{
  services.syncthing = {
    enable = true;
  };
}