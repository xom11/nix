{
  config,
  lib,
  pkgs,
  getRelPath,
  ...
}: let
  relPath = getRelPath ./.;
  pathList = ["modules"] ++ (lib.splitString "/" relPath);
  cfg = lib.getAttrFromPath pathList config;
in {
  # Like sway.nix/hyprland.nix: nixpkgs' `programs.niri` installs the session
  # .desktop and pulls in portals, dbus and polkit. The home-manager side owns
  # config.kdl. What LISTS the session at login is the display manager.
  config = lib.mkIf (cfg.enable && builtins.elem "niri" cfg.types) {
    programs.niri = {
      enable = true;

      # nixpkgs defaults this to true, which pulls nautilus in through
      # services.dbus.packages for the GNOME portal's FileChooser -- letting it
      # back in through the side door on a host that deliberately drops GNOME's
      # core apps. Off, the module switches FileChooser to "gtk".
      useNautilus = false;
    };

    # LANDMINE, blocked by hand. nixpkgs' `programs.niri` sets
    # `defaultSession = lib.mkDefault "niri"` so a niri-only setup does not loop at
    # login. Here that breaks two things at once, both silently:
    #   1. GDM's preStart runs `set-session` only when defaultSession is non-null,
    #      overwriting the user's AccountsService session choice on every start --
    #      nixpkgs' own comment calls it "basically ignore session history".
    #   2. nixos/base enables autoLogin, which uses defaultSession -- so the machine
    #      logs straight into niri and the fallback session stops being a fallback.
    #
    # `null` (a plain assignment, priority 100, beating mkDefault) restores the
    # pre-niri behaviour, keeping `SetSession` over D-Bus effective. Override this
    # in a host that genuinely wants niri as its default, do not delete the line.
    services.displayManager.defaultSession = null;

    # niri >= 25.08 creates the X11 socket, sets $DISPLAY and spawns
    # xwayland-satellite on demand, so it only needs the binary on PATH -- no
    # `xwayland enable` equivalent. systemPackages, not home.packages: the PATH
    # niri uses is the one `niri-session` loads into the systemd user manager.
    #
    # Needed for the same reason as on hyprland: Zalo and some older Electron apps
    # are X11-only, and without it they fail to open with no message.
    environment.systemPackages = [pkgs.xwayland-satellite];
  };
}
