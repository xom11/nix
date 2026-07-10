{
  config,
  lib,
  pkgs,
  mkModule,
  repoPath,
  ...
}:
mkModule config ./. {
  # A user service, not a system one: kanata does not need root, only access to
  # /dev/uinput (group uinput) and /dev/input/event* (group input). Granting
  # those is one-time root setup that lives outside home-manager — see README.md.
  systemd.user.services.kanata = {
    Unit = {
      Description = "kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };

    Service = {
      # kanata-with-cmd so (cmd ...) actions work; default pkgs.kanata refuses cmd
      ExecStart = "${lib.getBin pkgs.kanata-with-cmd}/bin/kanata --cfg ${repoPath}/configs/kanata/kanata_ubuntu.kbd";
      # kanata runs with a minimal PATH; give cmd actions the binaries they call
      Environment = ["PATH=${lib.makeBinPath [pkgs.coreutils pkgs.util-linux]}"];
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install.WantedBy = ["default.target"];
  };
}
