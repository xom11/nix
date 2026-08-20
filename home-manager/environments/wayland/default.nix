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
    # Shared by EVERY Wayland session. It exists because sway and hyprland both run
    # on rog, and if both declared ~/.config/mako/config home-manager would fail at
    # eval with a duplicate definition.
    #
    # Deliberately NOT auto-enabled by sway/hyprland: each host lists everything it
    # gets, per this repo's one-host-is-one-inventory rule.
    home.file = {
      ".config/mako/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/mako.d/config";
      };
      ".config/kanshi/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/kanshi.d/kanshi.conf";
      };
      ".config/swaylock/config" = {
        source = config.lib.file.mkOutOfStoreSymlink "${pwd}/swaylock.d/config";
      };
    };
    home.packages = with pkgs; [
      beckon
      libnotify
      mako
      wl-clipboard
      brightnessctl
      # `rofi`, NOT `rofi-wayland`: nixpkgs merged them and the old name is now an
      # alias that throws.
      rofi
      grim
      slurp
      swaybg
      swayidle
      # swaylock was once MISSING from the sway module although its config called
      # it in four places: the screen simply never locked, because swayidle ran a
      # nonexistent command and said nothing.
      swaylock
      cliphist
      kanshi
      wtype
      jq
      bluetui
    ];
  }
