{
  config,
  pkgs,
  getPath,
  mkModule,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # Shared by EVERY Wayland session (sway and hyprland both run on rog).
    # Notifications, lock screen, idle, wallpaper and monitor profiles are DMS's
    # job since 2026-08-22 — the `dms` module owns those, this one keeps only the
    # small tools both sessions call from their keybinds and scripts.
    #
    # Deliberately NOT auto-enabled by sway/hyprland: each host lists everything it
    # gets, per this repo's one-host-is-one-inventory rule.
    home.packages = with pkgs; [
      beckon
      libnotify
      wl-clipboard
      brightnessctl
      # `rofi`, NOT `rofi-wayland`: nixpkgs merged them and the old name is now an
      # alias that throws.
      rofi
      grim
      slurp
      cliphist
      wtype
      jq
      bluetui
    ];
  }
