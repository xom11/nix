{
  config,
  mkModule,
  device,
  ...
}:
mkModule config ./. {
  home.shellAliases = {
    update = ''
      git -C ~nix pull
      sudo nixos-rebuild switch --impure --refresh --flake ~/.nix#${device}
    '';
  };
}
