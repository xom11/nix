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
      # `"zap"` would work now (nix-darwin passes --force-cleanup, which no
      # longer prompts), but stays off: AI agents install brew packages mid-task,
      # and a cleanup would delete exactly what they are relying on.
      # Prune by hand -- without `--force` it only lists:
      #   bf=$(grep -o "/nix/store/[^']*-Brewfile" /run/current-system/activate)
      #   HOMEBREW_NO_REQUIRE_TAP_TRUST=1 brew bundle cleanup --file="$bf"
      cleanup = "none";
      # Homebrew >= 6.0 wants `brew trust` for non-official taps before bundle
      # will load them; without this, activation fails on the taps below.
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
    };

    masApps = {
    };

    taps = [
      # "homebrew-zathura/zathura" # zathura
      "kunkka19xx/tap" # look
      "xom11/tap" # beckon
    ];

    brews = [
      # Launcher. macOS takes it from brew only because `brew upgrade` beats
      # editing flake.lock -- NOT to keep the Accessibility grant across versions.
      # Measured: TCC stores the versioned Cellar path (it resolves the symlink),
      # and the designated requirement is a bare `cdhash` since the binary is
      # adhoc-signed, so every new build must be re-granted regardless of path.
      # Only Developer ID signing would fix that.
      # Diagnosing it by log does not work: "Accessibility is not granted"
      # appears at startup either way, then flips to "granted" seconds later.
      # Read TCC.db instead.
      #
      # The formula ships its own launch agent, so both mac hosts set
      # `programs.beckon-serve.enable = false` -- two agents on one chord means
      # the second registration silently loses.
      "xom11/tap/beckon"
      "npm"
      "colima"
      "docker"
      "docker-compose"
      "kanata"
      # "lima"
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
      # nixpkgs has it, but GUI apps come from brew for the same reason kanata
      # does: TCC keys grants to the bundle path, and a store path that changes
      # on each bump silently drops the Accessibility permission.
      "maccy"
      # "microsoft-edge"
      # "miniconda"
      # "nomachine"
      "notion"
      # "orbstack"
      # Dropped for look, which wants the same Cmd+Space; the loser is silent.
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
