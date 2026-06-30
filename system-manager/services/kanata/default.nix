{
  config,
  mkModule,
  lib,
  pkgs,
  ...
}: let
  configPath = "/home/kln/.nix/configs/kanata/kanata_ubuntu.kbd";
in
  mkModule config ./. {
    systemd.services.kanata = {
      description = "kanata";
      enable = true;
      wantedBy = ["system-manager.target"];
      serviceConfig = {
      };
      # kanata-with-cmd so (cmd ...) actions work; service runs as root (no hardening)
      script = ''
        ${lib.getBin pkgs.kanata-with-cmd}/bin/kanata -c ${configPath}
      '';
    };
  }
