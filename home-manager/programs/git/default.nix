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
        email = "khanhkhanhlele";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
