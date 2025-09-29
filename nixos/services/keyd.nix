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
          };
          otherlayer = {};
        };
        extraConfig = ''
          [cap_layer:C-M-A]
            equal = XF86AudioRaiseVolume
            minus = XF86AudioLowerVolume
            0 = XF86AudioMute

          [tab_layer:C-M-A-S]
            h = left
            j = down
            k = up
            l = right
            y = home
            u = pagedown
            i = pageup
            o = end

            equal = X86MonBrightnessUp
            minus = X86MonBrightnessDown
            0 = XF86AudioMicMute
            grave = Print
            
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