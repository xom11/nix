{ config, mkModule, pkgs, ... }:
mkModule config ./. {
  environment.etc."keyd/default.conf".text = ''
    [ids]
    *
    [main]
    capslock=overload(cap_layer, esc)
    tab=overload(tab_layer, tab)

    [cap_layer:C-M-A]

    [tab_layer:C-M-A-S]
    h = left
    j = down
    k = up
    l = right
    y = home
    u = pgup
    i = pgdown
    o = end
  '';
  environment.systemPackages = [ pkgs.keyd ];
  systemd.services.keyd = {
    enable = true;
    description = "Keyd Keyboard Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
    };
  };
}
