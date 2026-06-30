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
      # cmd_allowed build so (cmd ...) actions work; default pkgs.kanata refuses cmd
      package = pkgs.kanata-with-cmd;
      keyboards = {
        default = {
          extraDefCfg = "danger-enable-cmd yes";
          config = configFile;
        };
      };
    };
    # kanata runs with a minimal PATH; give cmd actions the binaries they call
    systemd.services."kanata-default".path = [pkgs.coreutils pkgs.util-linux];
  }
