{
  lib,
  username,
  device,
  ...
}: let
  # `hw.model` của từng máy darwin trong repo.
  #
  # Bảng này tồn tại vì ba dòng `networking` bên dưới đặt tên máy theo `device` --
  # tức là theo cái tên bạn gõ sau `#`. Gõ nhầm host thì máy vừa bị đổi tên vừa
  # nhận cấu hình của máy khác, và không có gì báo.
  #
  # Tệ hơn: alias `update` (home-manager/base/macos) cũng sinh ra từ `device`, nên
  # một lần nhầm sẽ viết lại alias thành host sai, và mọi `update` sau đó giữ
  # nguyên cái sai. Nó không bao giờ tự khỏi.
  #
  # Đã xảy ra thật: macmini từng chạy `#airm3` và mang tên `airm3` cho tới khi bị
  # phát hiện, vì `hostname` là thứ duy nhất người ta nhìn để biết mình đang ở máy nào.
  #
  # Máy chưa có trong bảng thì bỏ qua kiểm -- thêm một dòng khi biết `hw.model`
  # của nó (`sysctl -n hw.model`).
  expectedModels = {
    macmini = "Mac16,10";
    airm3 = "Mac15,13";
  };
  expected = expectedModels.${device} or null;

  # Tra ngược để báo lỗi nói được luôn lệnh đúng, thay vì chỉ nói là sai.
  reverseCase =
    lib.concatStringsSep "\n"
    (lib.mapAttrsToList (host: model: "      ${model}) right=${host} ;;") expectedModels);
in {
  # Chạy trong system.checks, tức là trước MỌI thứ khác trong activate (đặt tên
  # máy mãi tận cuối). Trượt ở đây thì chưa có gì bị đụng tới.
  system.checks.text = lib.optionalString (expected != null) ''
    actualModel=$(sysctl -n hw.model)
    if [ "$actualModel" != "${expected}" ]; then
      right=
      case "$actualModel" in
    ${reverseCase}
      esac
      printf >&2 '\e[1;31merror: dang ap cau hinh cua host `%s` len mot may khac\e[0m\n' '${device}'
      printf >&2 '\n'
      printf >&2 '  host `%s` mong doi hw.model = %s\n' '${device}' '${expected}'
      printf >&2 '  may nay la                   %s\n' "$actualModel"
      printf >&2 '\n'
      if [ -n "$right" ]; then
        printf >&2 '  Lenh dung cho may nay:\n'
        printf >&2 '    sudo darwin-rebuild switch --impure --flake ~/.nix#%s\n' "$right"
      else
        printf >&2 '  May nay chua co trong expectedModels o nix-darwin/setting/default.nix.\n'
      fi
      printf >&2 '\n'
      printf >&2 '  Neu van muon chay, sua bang tay -- dung `--flake` khac di.\n'
      exit 2
    fi
  '';

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
          com.apple.swipescrolldirection = false;
          #  disable windows opening animations
          NSAutomaticWindowAnimationsEnabled = false;
          com.apple.trackpad.scaling = 3;
        };
        "com.apple.Spotlight" = {
          PasteboardHistoryVersion = 2;
        };
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # To find the ID of a specific shortcut, you can use:
            # ============================
            # defaults read com.apple.symbolichotkeys > before.txt
            # edit ...
            # defaults read com.apple.symbolichotkeys > after.txt
            # diff -C 5 before.txt after.txt
            # ============================

            # 'Cmd + Space' for Spotlight Search
            "64" = {
              enabled = false;
            };
            # 'Cmd + Alt + Space' for Finder search window
            "65" = {
              enabled = false;
            };
            # Install fcitx5-for-mac better for vietnamese input method
            # 'Ctrl + Space' Select the previous input source
            "60" = {
              enabled = true;
            };

            # 'Ctrl + Opt + Space' Select the next input source
            "61" = {
              enabled = true;
            };

            # 'Ctrl + Opt + Cmd + 8' Reverse black and white
            "21" = {
              enabled = false;
            };
            # 'Ctrl + Opt + Cmd + .' Increase display contrast
            "25" = {
              enabled = false;
            };
            # 'Ctrl + Opt + Cmd + ,' Decrease display contrast
            "26" = {
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
        # Aerospace setting to group windows by app in Mission Control
        "com.apple.dock" = {
          expose-group-apps = true;
        };
      };
    };
  };
}
