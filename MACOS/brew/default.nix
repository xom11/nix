{ pkgs, ... }: 
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
    ];

    brews = [
      "tailscale"
      "podman"
      "openssl@3"
      "redis"
      "docker"
      "colima"
    ];

    casks = [
      "messenger"
      "zalo"
      "evkey"
      "notion"
      "balenaetcher"
      "bitwarden"
      "raycast"
      "discord"
      "visual-studio-code"
      "telegram"
      "localsend"
      "slack"
      "brave-browser"
      "qutebrowser"
      "google-chrome"
      "microsoft-edge"
      "xquartz"
      "kitty"
      "vmware-fusion"
      "miniconda"
      # "Tunnelblick"
      # "chromedriver"
    ];
  };
}