{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    # guiAddress =  "0.0.0.0:8384";
  };
}

