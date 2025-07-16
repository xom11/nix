{ config, lib, pkgs, ... }:
{
  environment = {
    etc = {
      "foo.conf".text = ''
        launch_the_rockets = true
      '';
      "keyd/config".text = ''
        [general]
        default_layout = "us"
        default_variant = "dvorak"
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