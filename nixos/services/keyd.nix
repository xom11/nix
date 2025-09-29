{...}:
{
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(cap, esc)";
            tab = "overload(hyper, tab)";
            leftcontrol = "overload(control, C-c)";
            leftalt = "overload(alt, C-v)";
          };
          otherlayer = {};
        };
        extraConfig = ''
          [cap:C-M-A]
          [hyper:C-M-A-S]
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