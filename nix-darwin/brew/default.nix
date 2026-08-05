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
      # Prunes anything installed but not declared above. Was off for a while:
      # Homebrew 6.0 deprecated `brew bundle --cleanup`, so activation printed a
      # warning and prompted "proceed with the cleanup? [y/n]" on every `update`.
      # nix-darwin now emits `--zap --force-cleanup` instead (modules/homebrew.nix),
      # and `--force-cleanup` is documented as cleaning up *without asking* — so
      # the prompt can no longer stall a switch.
      cleanup = "zap";
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
      "syncthing"
    ];

    casks = [
      "claude"
      # Launcher. Only macOS gets it from brew: upstream ships a signed and
      # notarized .app here, and its Nix flake (apps/linows) declares
      # meta.platforms = linux -- there is no darwin derivation to use instead.
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
      # Clipboard manager. nixpkgs has it, but every GUI .app here comes from
      # brew for the same reason kanata does: TCC grants are keyed to the bundle
      # path, so a store path that changes on each bump silently drops the
      # Accessibility permission Maccy needs in order to paste.
      "maccy"
      "microsoft-edge"
      # "miniconda"
      # "nikitabobko/tap/aerospace"
      "nomachine"
      "notion"
      # "orbstack"
      # "qutebrowser"
      # Dropped for look, which wants the same Cmd+Space. Two launchers on one
      # hotkey means whichever registered it last wins, silently.
      # "raycast"
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
