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
        name = "namkhanh20xx";
        email = "namkhanh20xx@gmail.com";
      };
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
