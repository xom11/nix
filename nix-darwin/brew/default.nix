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
      # Homebrew 6.0 deprecated `brew bundle --cleanup` ("no replacement"), and
      # passing it makes activation print a deprecation warning and prompt
      # "Do you want to proceed with the cleanup? [y/n]" on every `update`.
      # Keep it off; prune undeclared/old packages manually when needed with
      # `brew bundle cleanup --force` or `brew cleanup`.
      cleanup = "none";
      # Homebrew >= 6.0 requires non-official taps to be trusted via `brew trust`
      # before `brew bundle` will load their formulae/casks. Disable that check
      # so activation doesn't fail on our third-party taps below.
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
    };

    masApps = {
    };

    taps = [
      # "homebrew-zathura/zathura" # zathura
      "laishulu/homebrew" # macism
      "kunkka19xx/tap"
    ];

    brews = [
      "npm"
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

    casks = [
      "claude"
      "look"
      "obsidian"
      "gonhanh"
      "monitorcontrol"
      "vivaldi"
      "firefox"
      # "Tunnelblick"
      # "android-platform-tools"
      "balenaetcher"
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
      "kitty"
      # "localsend"
      "microsoft-edge"
      # "miniconda"
      # "nikitabobko/tap/aerospace"
      "nomachine"
      "notion"
      # "orbstack"
      # "qutebrowser"
      "raycast"
      # "rustdesk"
      # "scroll-reverser"
      # "slack"
      "telegram"
      # "visual-studio-code"
      "vlc"
      # "zalo"
    ];
  };
}
