{
  config,
  mkModule,
  repoPath,
  ...
}: let
  configPath = "${repoPath}/configs/kanata";
  configFile =
    builtins.readFile "${configPath}/kanata_nixos.kbd"
    + builtins.readFile "${configPath}/main.kbd";
in
  mkModule config ./. {
    services.kanata = {
      enable = true;
      keyboards = {
        default = {
          config = configFile;
        };
      };
    };
  }
