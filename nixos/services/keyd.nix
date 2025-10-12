{...}:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(cap_layer, esc)";
            tab = "overload(tab_layer, tab)";
            leftcontrol = "overload(control, C-c)";
            leftalt = "overload(alt, C-v)";

            a = "overloadt(shift, a, 200)";
            s = "overloadt(alt, s, 200)";
            d = "overloadt(meta, d, 200)";
            f = "overloadt(control, f, 200)";
            j = "overloadt(control, j, 200)";
            k = "overloadt(meta, k, 200)";
            l = "overloadt(alt, l, 200)";
            ";" = "overloadt(shift, ;, 200)";
            
          };
          otherlayer = {};
        };
        extraConfig = ''
          [cap_layer:C-M-A]


          [tab_layer:C-M-A-S]
            h = left
            j = down
            k = up
            l = right
            y = home
            u = pagedown
            i = pageup
            o = end
        '';
      };
    };
  };
  # Optional, but makes sure that when you type the make palm rejection work with keyd
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';
}
