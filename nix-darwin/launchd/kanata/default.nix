{
  config,
  pkgs,
  mkModule,
  getPath,
  repoPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # https://github.com/jtroo/kanata/discussions/1537
    # macOS runs kanata as root via this daemon. Empirically (macmini, macOS Tahoe)
    # a root kanata opens the keyboard with ANY binary path/cdhash — no per-binary
    # Input Monitoring grant needed — so we point straight at the nix kanata-with-cmd
    # store path (dropped Homebrew, which cannot run `cmd` actions). The binary path
    # is passed to script.sh as $2 so nothing is hardcoded.
    launchd.daemons."kanata" = {
      command = "${pwd}/script.sh ${repoPath}/configs/kanata/kanata_macos.kbd ${pkgs.kanata-with-cmd}/bin/kanata";
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/Library/Logs/Kanata/kanata.out.log";
        StandardErrorPath = "/Library/Logs/Kanata/kanata.err.log";
      };
    };
    launchd.daemons."karabiner-driverkit" = {
      script = ''
        /Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon
      '';
      serviceConfig = {
        KeepAlive = true;
        ProcessType = "Interactive";
      };
    };

    # environment.etc."kanata/kanata.kbd".source = builtins.toString ./kanata.macos.kbd;
  }
