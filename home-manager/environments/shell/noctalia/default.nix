{
  pkgs,
  config,
  mkModule,
  ...
}:

mkModule config ./. {
  # Bundles its own quickshell fork (noctalia-qs), so no separate quickshell
  # package is needed -- unlike the dms module. nixpkgs ships the v4 legacy
  # line; v5 exists upstream only.
  home.packages = with pkgs; [
    noctalia-shell
  ];
}
