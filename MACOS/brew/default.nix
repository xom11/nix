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
      "podman"
      "openssl@3"
      "redis"
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
      "xournal++"
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