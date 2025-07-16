{ config, lib, pkgs, ... }:
{
  imports = [
    ./keyd.nix
    ./docker.nix
  ];
  environment = {
    etc = {
      "foo.conf".text = ''
        launch_the_rockets = true
      '';
    };
    systemPackages = [
      pkgs.ripgrep
      pkgs.fd
      pkgs.hello
    ];
  };

  systemd.services = {
    foo = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      wantedBy = [ "system-manager.target" ];
      script = ''
        ${lib.getBin pkgs.hello}/bin/hello
        echo "We launched the rockets!"
      '';
    };
  };
}