{
  config,
  pkgs,
  repoPath,
  mkModule,
  ...
}: let
  # A string into the working tree (the mkOutOfStoreSymlink idea): serve's watcher
  # picks up edits without a switch.
  configFile = "${repoPath}/configs/shortcuts/apps.shared.toml";
  label = "com.xom11.beckon-serve";
  logDir = "${config.home.homeDirectory}/Library/Logs/beckon";
in
  mkModule config ./. {
    # launchd does NOT create the parent of StandardOutPath, so the agent fails to
    # start on a clean machine. A .keep file beats an activation script that only
    # calls mkdir.
    home.file."Library/Logs/beckon/.keep".text = "";

    launchd.agents.beckon-serve = {
      enable = true;
      config = {
        Label = label;
        # Straight into the store, no stable path in between. beckon only needs
        # Accessibility for window cycling, which was dropped -- registering
        # hotkeys, launching, focusing and hiding need no grant at all, so there
        # is no grant to anchor to a fixed path.
        #
        # A store path in the plist also means every bump changes the plist, and
        # home-manager compares plists and re-bootstraps the agent, so it picks up
        # the new binary on its own. Hence no `launchctl kickstart -k`.
        ProgramArguments = ["${pkgs.beckon}/bin/beckon" "serve" configFile];
        RunAtLoad = true;
        # serve never exits successfully, so any exit is a relaunch. The 60 s
        # throttle follows agenix: no 10 s crash loop on a broken binary or config.
        KeepAlive = {SuccessfulExit = false;};
        ThrottleInterval = 60;
        # Hotkeys only live in a GUI session; this also prevents the "started from
        # SSH and receives no events" trap by pinning the agent to the Aqua session.
        LimitLoadToSessionType = "Aqua";
        StandardOutPath = "${logDir}/serve.log";
        StandardErrorPath = "${logDir}/serve.log";
      };
    };
  }
