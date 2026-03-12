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
      credential.helper = "store"; # Cache credentials on disk (plain text, ~/.git-credentials)
      push.autoSetupRemote = true; # Auto-set upstream on first push without needing -u origin <branch>
    };
  };
}
