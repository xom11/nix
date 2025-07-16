{ config, lib, pkgs, ... }:
{
  environment = {
    etc = {
      "keyd/default.conf".text = ''
        [ids]
        *
        [main]
        capslock=overload(hyper, esc)
        [hyper:C-M-A]
      '';
    };
  };
  # systemd.services = {
  #   keyd = {
  #     enable = true;
  #     description = "Keyd Keyboard Daemon";
  #     serviceConfig = {
  #       Type = "simple";
  #       ExecStart = "${pkgs.keyd}/bin/keyd --config /etc/keyd/default.conf";
  #     };
  #     wantedBy = [ "multi-user.target" ];
  #   };
  # };
}