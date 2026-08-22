{
  pkgs,
  config,
  mkModule,
  ...
}:

mkModule config ./. {
  # `dms` execs `qs` at startup, so quickshell must sit next to it in PATH.
  # Disabled on rog since 2026-08-22 in favour of shell/noctalia -- re-enable
  # there and swap the two autostart/lock lines per session to revert.
  home.packages = with pkgs; [
    dms-shell
    quickshell
  ];
}
