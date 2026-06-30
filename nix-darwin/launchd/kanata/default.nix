{
  config,
  pkgs,
  mkModule,
  getPath,
  repoPath,
  ...
}: let
  pwd = getPath ./.;
  # cmd_allowed build from nixpkgs (replaces the Homebrew kanata, which never allows cmd)
  kanataBin = "${pkgs.kanata-with-cmd}/bin/kanata";
in
  mkModule config ./. {
    # https://github.com/jtroo/kanata/discussions/1537
    launchd.daemons."kanata" = {
      # command = "sudo /opt/homebrew/bin/kanata -c ${pwd}/kanata.macos.kbd -n";
      command = "${pwd}/script.sh ${repoPath}/configs/kanata/kanata_macos.kbd ${kanataBin}";
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
