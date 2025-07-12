{
  system = {
    defaults = {
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.15;
        dashboard-in-overlay = false;
        enable-spring-load-actions-on-all-items = false;
        expose-animation-duration = 0.2;
        expose-group-apps = false;
        launchanim = true;
        mineffect = "genie";
        minimize-to-application = false;
        mouse-over-hilite-stack = true;
        mru-spaces = false;
        orientation = "right";
        show-process-indicators = true;
        show-recents = true;
        showhidden = true;
        static-only = false;
        tilesize = 40;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        persistent-apps = [];
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
      # finder = {
      #   _FXShowPosixPathInTitle = false;
      #   _FXSortFoldersFirst = true;
      #   AppleShowAllExtensions = true;
      #   AppleShowAllFiles = false;
      #   CreateDesktop = true;
      #   FXDefaultSearchScope = "SCcf";
      #   FXEnableExtensionChangeWarning = false;
      #   FXPreferredViewStyle = "clmv";
      #   QuitMenuItem = false;
      #   ShowPathbar = true;
      #   ShowStatusBar = false;
      # };
      screencapture = {
        disable-shadow = true;
        location = "~/Downloads";
        show-thumbnail = true;
        type = "png";
        target = "file";
      };
      NSGlobalDomain = {
        _HIHideMenuBar = false;
        InitialKeyRepeat = 15; # slider values: 120, 94, 68, 35, 25, 15
        KeyRepeat = 2; # slider values: 120, 90, 60, 30, 12, 6, 2
      };

    };
  };
}