{
  config,
  homeDir,
  mkModule,
  device,
  ...
}:
mkModule config ./. {
  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#${device}";
  };
}
