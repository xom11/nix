{
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  environment.variables = {
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    masApps = {
    };

    taps = [
      # "homebrew-zathura/zathura" # zathura
      "laishulu/homebrew" # macism
    ];

    brews = [
      "colima"
      "docker"
      "docker-compose"
      "kanata"
      # "lima"
      "macism"
      "micromamba"
      "openssl@3"
      "podman"
      # "scrcpy"
      "sleepwatcher"
      "tailscale"
      "duti"
      "syncthing"
    ];

    caskArgs.no_quarantine = true;
    casks = [
      "obsidian"
      "gonhanh"
      "monitorcontrol"
      "vivaldi"
      "firefox"
      # "Tunnelblick"
      # "android-platform-tools"
      "balenaetcher"
      # "betterdisplay"
      "bitwarden"
      "brave-browser"
      # "chromedriver"
      # "deskreen"
      # "drawpen"
      # "duet"
      "google-chrome"
      "hammerspoon"
      "homerow"
      "karabiner-elements"
      # "kindavim"
      "kitty"
      # "lark"
      "localsend"
      # "microsoft-edge"
      # "miniconda"
      # "nikitabobko/tap/aerospace"
      "nomachine"
      "notion"
      # "orbstack"
      "qutebrowser"
      "raycast"
      # "rustdesk"
      # "scroll-reverser"
      # "slack"
      "telegram"
      "visual-studio-code"
      "vlc"
      "zalo"
    ];
  };
}
