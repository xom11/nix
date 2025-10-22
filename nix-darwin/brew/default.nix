{lib, config, ... }: 
let
  cfg = config.modules.brew;
in
{
  options.modules.brew = {
    enable = lib.mkEnableOption "Enable Homebrew package manager";
  };
  config = lib.mkIf cfg.enable {
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
        "kanata"
        "micromamba"
        "sleepwatcher"
      ];

      caskArgs.no_quarantine = true;
      casks = [
        # "scroll-reverser"
        "drawpen"
        # "aerospace"
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
        # "qutebrowser"
        "google-chrome"
        # "kindavim"
        # "microsoft-edge"
        # "deskreen"
        "homerow"
        "xquartz"
        "kitty"
        # "vmware-fusion"
        # "miniconda"
        # "Tunnelblick"
        # "chromedriver"
      ];
    };
  };
}
