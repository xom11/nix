{
  pkgs,
  config,
  getPath,
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

  # Settings live IN THE REPO working tree via env override, NOT a symlink:
  # noctalia saves through quickshell FileView atomic writes (temp + rename),
  # and rename replaces a symlink instead of following it -- the dotpkg trap.
  # Consequence: tweaking the Settings UI dirties the repo tree; commit or
  # checkout to revert. plugins.json stays machine-local on purpose.
  home.sessionVariables.NOCTALIA_SETTINGS_FILE =
    "${getPath ./.}/settings.json";
}
