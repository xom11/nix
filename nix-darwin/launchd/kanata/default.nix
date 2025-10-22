{username,lib, config, ...}:
let 
  cfg = config.modules.launchd.kanata;
in 
{
  options.modules.launchd.kanata = {
    enable = lib.mkEnableOption "Enable kanata launchd service";
  };
  config = lib.mkIf cfg.enable {
    # https://github.com/jtroo/kanata/discussions/1537
    launchd.daemons."kanata" = {
      command = "sudo /opt/homebrew/bin/kanata -c /Users/${username}/.nix/nix-darwin/launchd/kanata/kanata.macos.kbd -n";
      # command = ''
      #   ${./script.sh}
      # '';
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
  };
}
