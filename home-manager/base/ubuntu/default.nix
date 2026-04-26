{
  config,
  homeDir,
  mkModule,
  ...
}:
mkModule config ./. {
  xdg.configFile."environment.d/99-nix-path.conf".text = ''
    PATH=${homeDir}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:''${PATH}
    XDG_DATA_DIRS=${homeDir}/.nix-profile/share:/nix/var/nix/profiles/default/share:''${XDG_DATA_DIRS}
  '';
}
