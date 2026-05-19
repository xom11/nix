{
  config,
  mkModule,
  getPath,
  repoPath,
  ...
}: let
  pwd = getPath ./.;
in
  mkModule config ./. {
    # https://github.com/jtroo/kanata/discussions/1537
    launchd.daemons."kanata" = {
      # command = "sudo /opt/homebrew/bin/kanata -c ${pwd}/kanata.macos.kbd -n";
      command = "${pwd}/script.sh ${repoPath}/configs/kanata/kanata_macos.kbd";
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

    environment.interactiveShellInit = ''
      kr() {
        local plist="/Library/LaunchDaemons/org.nixos.kanata.plist"
        local log_file=$(grep -A 1 "StandardErrorPath" "$plist" | grep "string" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')

        sudo launchctl unload "$plist"
        sudo launchctl load "$plist"

        if [ -n "$log_file" ]; then
          sleep 1
          echo "LOG FILE: $log_file"
          sudo tail -n 20 "$log_file"
          echo "------------------------------"
          echo "kanata path:"
          which kanata
        else
          echo "Warning: Could not find log file path in $plist. Please check the plist file for the correct log file location."
        fi
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
      }

      ks() {
        local plist="/Library/LaunchDaemons/org.nixos.kanata.plist"
        sudo launchctl unload "$plist"
        echo "kanata stopped."
      }
    '';
    # environment.etc."kanata/kanata.kbd".source = builtins.toString ./kanata.macos.kbd;
  }
