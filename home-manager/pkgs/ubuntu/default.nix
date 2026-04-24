{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.aptPackages = [
    "kitty"
  ];
}
