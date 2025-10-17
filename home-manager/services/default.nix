{ pkgs, lib, device, ... }:

{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384"; # 127.0.0.1:8384
  };
}