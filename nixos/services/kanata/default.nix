{
  config,
  pkgs,
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
      package = pkgs.kanata;
      keyboards = {
        default = {
          # match the shared defcfg.kbd the other platforms include
          extraDefCfg = "process-unmapped-keys yes";
          config = configFile;
        };
      };
    };
  }
