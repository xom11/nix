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
      "docker"
    ];

    casks = [
      "simplenote"
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
      "joplin"
      "slack"
      "brave-browser"
      "google-chrome"
      "microsoft-edge"
      "kitty"
      "vmware-fusion"
      "rustdesk"
      # "Tunnelblick"
      # "chromedriver"
    ];
  };
}