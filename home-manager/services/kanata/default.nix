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
      # notify: kanata signals readiness when it enters the processing loop, same
      # as the nixpkgs services.kanata module. Restart=no: a keyboard grabber
      # shouldn't respawn — on a permission failure it would just loop (which is
      # what the community's systemd unit settled on, jtroo/kanata#130).
      Type = "notify";
      Restart = "no";
    };

    Install.WantedBy = ["default.target"];
  };
}
