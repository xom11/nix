# Viet+ (vietc) -- a direct-input Vietnamese IME, an alternative to fcitx5.
#
# ENABLED ON NO HOST, deliberately. vietc picks one of three backends once at
# startup, and which one decides whether this is worth enabling at all:
#   1. zwp_input_method_v2 -- covers native Wayland apps including kitty. sway and
#      Hyprland have it; Mutter does not (measured). The only one we want.
#   2. evdev grab + uinput -- covers everything but needs EVIOCGRAB on the real
#      keyboard, which kanata already holds. Hence `grab = false` in config.toml.
#   3. X11 XTEST -- covers only X11/XWayland windows, so not kitty. This is where
#      vietc lands under GNOME, which is why enabling it there is pointless.
#
# To enable, set `programs.vietc.enable` in the host and turn fcitx5 OFF at the
# same time (drop `environments.i18n.enable`, the `exec_always fcitx5 -rd` line,
# and the `fcitx5-remote` keybindings). Nothing asserts this: two IMEs running
# together shows up as duplicated or swallowed characters, not an error.
{
  config,
  pkgs,
  mkModule,
  getPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    home.packages = [pkgs.vietc];

    # An out-of-store symlink is safe here because the daemon only READS this
    # file -- it writes overrides.toml beside it, deliberately left unmanaged.
    # (fcitx5 taught the opposite case: it overwrites through the symlink.)
    home.file."${config.xdg.configHome}/vietc/config.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${pwd}/vietc.d/config.toml";
    };

    systemd.user.services.vietc = {
      Unit = {
        Description = "Viet+ Vietnamese IME daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.vietc}/bin/vietc";
        Restart = "on-failure";
        RestartSec = 3;
        # IbusRestartGuard spawns ibus-daemon inside this service's cgroup, so the
        # default `control-group` kill mode would take IBus down with vietc.
        KillMode = "process";
      };

      # Upstream's unit has ConditionEnvironment=DISPLAY; deliberately not copied.
      # It exists to force backend 3, but we want backend 1 on sway, where DISPLAY
      # may not exist -- keeping it means the service silently never starts.
      Install.WantedBy = ["graphical-session.target"];
    };
  }
