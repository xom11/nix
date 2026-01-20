# FIX: tab to click and NaturalScrolling
{...}: {
  environment.etc."X11/xorg.conf.d/40-libinput.conf".text = ''
    Section "InputClass"
      Identifier "touchpad"
      MatchIsTouchpad "on"
      Driver "libinput"
      Option "Tapping" "on"
      Option "NaturalScrolling" "true"
    EndSection
  '';
}
