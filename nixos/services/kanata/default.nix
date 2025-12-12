{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        config = builtins.readFile ./kanata.kbd;
      };
    };
  };
}
