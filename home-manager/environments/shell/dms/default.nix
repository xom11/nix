{
  pkgs,
  config,
  mkModule,
  ...
}:

mkModule config ./. {
  # `dms` execs `qs` at startup, so quickshell must sit next to it in PATH.
  # DMS owns org.freedesktop.Notifications, lock, idle, wallpaper and monitor
  # profiles in BOTH Wayland sessions on rog; both autostarts call `dms run`.
  home.packages = with pkgs; [
    dms-shell
    quickshell
  ];
}
