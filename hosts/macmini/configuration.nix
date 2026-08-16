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
    # dotbrave KHONG con o tang nao cua rebuild nua (16/08/2026) -- ATTIC.md,
    # `attic/dotbrave-modules-2026-08-16`. brave.toml van trong repo va binary
    # van trong PATH (home.nix), ap bang tay. CON MOT VIEC PHAI LAM TAY tren
    # may nay: managed plist cu bi ghim schg, xem ATTIC.md.
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
