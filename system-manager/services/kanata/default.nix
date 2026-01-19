{
  lib,
  pkgs,
  ...
}: let
  configPath = "/home/kln/.nix/configs/kanata/kanata_windows.kbd";
in {
  systemd.services.kanata = {
    description = "kanata";
    enable = true;
    wantedBy = ["system-manager.target"];
    serviceConfig = {
    };
    script = ''
      ${lib.getBin pkgs.kanata}/bin/kanata -c ${configPath}
    '';
  };
}
