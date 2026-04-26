{
  config,
  homeDir,
  mkModule,
  device,
  ...
}:
mkModule config ./. {
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake ~/.nix#${device}
    '';
    system-manager-update = ''
      sudo /nix/var/nix/profiles/default/bin/nix run 'github:numtide/system-manager' -- switch --flake ~/.nix#${device}
    '';
  };
  home.sessionPath = [
    "/run/system-manager/sw/bin"
  ];
  xdg.configFile."environment.d/99-nix-path.conf".text = ''
    PATH=${homeDir}/.nix-profile/bin:/nix/var/nix/profiles/default/bin:''${PATH}
    XDG_DATA_DIRS=${homeDir}/.nix-profile/share:/nix/var/nix/profiles/default/share:''${XDG_DATA_DIRS}
  '';
}
