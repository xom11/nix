{
  lib,
  config,
  ...
}: {
  imports = [
    ../../nix-darwin
  ];
  modules.nix-darwin = {
    brew.enable = true;
    # dotbrave left the rebuild path entirely (see ATTIC.md); brave.toml and the
    # binary remain and are applied by hand. One manual cleanup is still pending
    # on this machine: the old managed plist is pinned with schg.
    launchd = {
      kanata.enable = true;
    };
  };
  nix.settings = {
    max-jobs = "auto";
    cores = 0; # 0 nghĩa là sử dụng tất cả các nhân
  };

  # Enable darwin-specific settings
  power.sleep = {
    computer = "never"; # never go to sleep when idle
  };
  environment.systemPath = [
    # "/opt/homebrew/opt/postgresql@18/bin"
  ];
  homebrew = {
    brews = [
      "redis"
      # "postgresql"
      # "nginx"
      "httpie"
      "ollama"
      # "livekit"
      "ffmpeg@6"
      "mkcert"
      "caddy"
    ];
    casks = [
      # "dbeaver-community"
      # "postman"
      # "xquartz"
      # "beeper"
      "tablepro"
      "macs-fan-control"
    ];
  };
}
