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
      # "homebrew-zathura/zathura"
      "laishulu/homebrew"
    ];

    brews = [
      "colima"
      "docker"
      "docker-compose"
      "kanata"
      "micromamba"
      "openssl@3"
      "podman"
      "redis"
      "sleepwatcher"
      "tailscale"
      "macism"
      "scrcpy"
      # "zathura"
    ];

    caskArgs.no_quarantine = true;
    casks = [
      "android-platform-tools"
      # "Tunnelblick"
      "balenaetcher"
      "bitwarden"
      "brave-browser"
      # "chromedriver"
      # "cursor"
      # "deskreen"
      # "discord"
      # "drawpen"
      # "duet"
      # "evkey"
      "google-chrome"
      "hammerspoon"
      "homerow"
      "karabiner-elements"
      # "kindavim"
      "kitty"
      "lark"
      "localsend"
      # "microsoft-edge"
      # "miniconda"
      # "nikitabobko/tap/aerospace"
      "notion"
      "nomachine"
      # "qutebrowser"
      "raycast"
      # "rustdesk"
      # "scroll-reverser"
      # "slack"
      "telegram"
      "visual-studio-code"
      "vlc"
      # "vmware-fusion"
      "xquartz"
      "zalo"
    ];
  };
}
