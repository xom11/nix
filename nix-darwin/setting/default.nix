{ lib, username, device, ... }:
{
  networking = {
    computerName = lib.mkDefault device;
    hostName = lib.mkDefault device;
    localHostName = lib.mkDefault device;
    wakeOnLan.enable = true;
  };
  power.sleep = {
    # Amount of idle time (in minutes) until the computer sleeps
    computer = lib.mkDefault 60;
    # Amount of idle time (in minutes) until displays sleep
    display = lib.mkDefault 60;
    # Amount of idle time (in minutes) until hard disks sleep
    # harddisk = lib.mkDefault 60; # ignore because of SSD
  };
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
        largesize = 60;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
        persistent-apps = [];
      };
      finder = {
        ShowPathbar = true;
        ShowStatusBar = true;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
      };
      trackpad = {
        Clicking = true;
        # For normal click: 0 for light clicking, 1 for medium, 2 for firm
        FirstClickThreshold = 0;
        # For force touch: 0 for light clicking, 1 for medium, 2 for firm
        SecondClickThreshold = 1;
        TrackpadThreeFingerDrag = false;
        Dragging = true;
      };
      controlcenter = {
        AirDrop = false;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
      };
      screencapture = {
        disable-shadow = true;
        location = "~/Downloads";
        show-thumbnail = true;
        type = "png";
        target = "file";
      };
      NSGlobalDomain = {
        InitialKeyRepeat = 15; # slider values: 120, 94, 68, 35, 25, 15
        KeyRepeat = 2; # slider values: 120, 90, 60, 30, 12, 6, 2
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = true;
      };
      CustomUserPreferences = {
        NSGlobalDomain = {
          AppleLanguages = ["en"];
          #  moving window by holding anywhere on it like on Linux
          NSWindowShouldDragOnGesture = true;
          #  smooth scrolling
          NSScrollAnimationEnabled = true;
          #  natural scrolling
          # com.apple.swipescrolldirection = false;
          com.apple.trackpad.scaling = 3;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Disable 'Cmd + Space' for Spotlight Search
            "64" = {
              enabled = false;
            };
            # Disable 'Cmd + Alt + Space' for Finder search window
            "65" = {
              enabled = false;
            };
          };
        };
        "com.apple.screensaver" = {
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.hitoolbox" = {
          AppleFnUsageType = 0;
        };
      };
    };
  };
}  
