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
      # `"zap"` is usable again, and the old reason for avoiding it is gone:
      # Homebrew 6.0 deprecated `brew bundle --cleanup`, which made activation
      # prompt "proceed with the cleanup? [y/n]" on every `update`. nix-darwin
      # now emits `--zap --force-cleanup` instead, and `--force-cleanup` cleans
      # up *without asking*, so it can no longer stall a switch.
      #
      # Still kept off on purpose. AI coding agents install brew packages
      # mid-task to get their work done; those are undeclared by definition, so
      # a cleanup on the next `update` would delete exactly what an agent is
      # relying on. That is a worse failure than some drift.
      #
      # Prune by hand instead. Without `--force` it only lists:
      #   bf=$(grep -o "/nix/store/[^']*-Brewfile" /run/current-system/activate)
      #   HOMEBREW_NO_REQUIRE_TAP_TRUST=1 brew bundle cleanup --file="$bf"
      # The env var matters: without it the third-party taps below fail to load.
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
      "kunkka19xx/tap" # look
    ];

    brews = [
      "npm"
      "colima"
      "docker"
      "docker-compose"
      "kanata"
      # "lima"
      "micromamba"
      "openssl@3"
      "podman"
      # "scrcpy"
      "sleepwatcher"
      "tailscale"
      "duti"
    ];

    casks = [
      "claude"
      # Launcher. Only macOS gets it from brew: upstream ships a signed and
      # notarized .app here, and its Nix flake (apps/linows) declares
      # meta.platforms = linux -- there is no darwin derivation to use instead.
      "look"
      # "obsidian"
      "gonhanh"
      "monitorcontrol"
      # "vivaldi"
      # "Tunnelblick"
      # "android-platform-tools"
      "balenaetcher"
      # "bitwarden"
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
      # Clipboard manager. nixpkgs has it, but every GUI .app here comes from
      # brew for the same reason kanata does: TCC grants are keyed to the bundle
      # path, so a store path that changes on each bump silently drops the
      # Accessibility permission Maccy needs in order to paste.
      "maccy"
      # "microsoft-edge"
      # "miniconda"
      # "nomachine"
      "notion"
      # "orbstack"
      # Dropped for look, which wants the same Cmd+Space. Two launchers on one
      # hotkey means whichever registered it last wins, silently.
      # "raycast"
      # "rustdesk"
      # "scroll-reverser"
      # "slack"
      "telegram"
      # "visual-studio-code"
      # "vlc"
      # "zalo"
    ];
  };
}
