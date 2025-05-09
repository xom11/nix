{ config
, pkgs
, inputs
, lib
, ...
}:
{

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];


  nixpkgs.config.allowUnfreePredicate = (_: true);
  boot.loader.systemd-boot.configurationLimit = 5;
  # Garbage Collector Setting
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  environment.systemPackages = with pkgs;
    [
      brave
    ];

}