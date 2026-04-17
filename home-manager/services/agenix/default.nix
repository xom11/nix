{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  age.identityPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
}
