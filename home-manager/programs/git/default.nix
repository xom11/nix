{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "khanhkhanhlele";
        email = "namkhanh2172@gmail.com";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
