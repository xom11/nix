{ ... }: 
{
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
    ];

    brews = [
      # "zathura"
      "tailscale"
      "podman"
      "openssl@3"
      "redis"
      "docker"
      "colima"
    ];

    caskArgs.no_quarantine = true;
    casks = [
      "karabiner-elements"
      "messenger"
      "zalo"
      "evkey"
      "notion"
      "balenaetcher"
      "bitwarden"
      "raycast"
      "discord"
      "visual-studio-code"
      "vlc"
      "telegram"
      "localsend"
      # "slack"
      "brave-browser"
      "qutebrowser"
      # "google-chrome"
      # "kindavim"
      # "microsoft-edge"
      # "deskreen"
      "homerow"
      "xquartz"
      "kitty"
      "vmware-fusion"
      # "miniconda"
      # "Tunnelblick"
      # "chromedriver"
    ];
  };
}