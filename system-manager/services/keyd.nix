{ config, lib, pkgs, ... }:
{
  environment = {
    etc = {
      "keyd/default.conf".text = ''
        [ids]
        *
        [main]
        capslock=overload(cap_layer, esc)
        tab=overload(tab_layer, tab)
        a = overloadt(control, a, 200)

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
    };
    systemPackages = with pkgs; [
      keyd
    ];
  };
  systemd.services = {
    keyd = {
      enable = true;
      description = "Keyd Keyboard Daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.keyd}/bin/keyd";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
