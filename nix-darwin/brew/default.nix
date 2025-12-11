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
      laishulu/homebrew # macism
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
      # "zathura"
    ];

    caskArgs.no_quarantine = true;
    casks = [
      # "Tunnelblick"
      "balenaetcher"
      "bitwarden"
      "brave-browser"
      # "chromedriver"
      # "cursor"
      # "deskreen"
      "discord"
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
      "messenger"
      # "microsoft-edge"
      # "miniconda"
      # "nikitabobko/tap/aerospace"
      "notion"
      # "qutebrowser"
      "raycast"
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
