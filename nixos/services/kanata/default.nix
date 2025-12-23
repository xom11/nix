{
  config,
  mkModule,
repoPath,
  ...
}:
mkModule config ./. {
  services.kanata = {
    enable = true;
    keyboards = {
      default = {
        config = builtins.readFile "${repoPath}/configs/kanata/kanata_nixos.kbd";
      };
    };
  };
}
