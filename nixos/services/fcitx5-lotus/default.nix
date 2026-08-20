{
  config,
  pkgs,
  username,
  mkModule,
  ...
}:
# The SYSTEM half of fcitx5-lotus. The fcitx5 addon itself comes from
# home-manager/environments/i18n; this adds only what home-manager cannot reach,
# and without it lotus's four Uinput modes fail silently.
#
# Those modes use neither preedit nor surrounding text: they rely on a privileged
# `fcitx5-lotus-server` injecting real BackSpace through /dev/uinput -- the same
# mechanism GoNhanh uses on macOS and VKey on Windows. The other two modes take
# the ordinary fcitx5 path, and both underline in kitty, which is a byte stream
# and supplies no surrounding text, forcing the IME back to preedit.
#
# nixpkgs packages the binary, unit and udev rule but ships no NixOS module, so by
# default nothing loads them -- which is what rog looked like before 2026-08-16.
mkModule config ./. {
  # `uinput_proxy` is the user the upstream unit runs as, not the session user.
  users.users.uinput_proxy = {
    isSystemUser = true;
    group = "input";
  };

  # Sets /dev/uinput to 0660 root:input and ACLs rw for uinput_proxy. Without it
  # the server fails to open the device and exits, systemd restarts in a loop, and
  # the only user-visible symptom is that Uinput mode still underlines.
  services.udev.packages = [pkgs.fcitx5-lotus];

  # `systemd.packages` LOADS the unit template but does not ENABLE it: NixOS
  # ignores `[Install] WantedBy=` from packaged units, hence the wiring below.
  systemd.packages = [pkgs.fcitx5-lotus];

  # One instance per user: the server needs to know which user to match against
  # the running fcitx5. `username` reads $USER AT EVAL, so checking from another
  # machine shows that machine's name.
  systemd.targets.multi-user.wants = ["fcitx5-lotus-server@${username}.service"];
}
