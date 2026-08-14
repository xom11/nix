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
    # Bat CA HAI nua cua dotbrave: [pwa] o /Library/Managed Preferences bang
    # root, va [shortcuts] + [settings] o profile Brave bang quyen user (module
    # tu bat ho ben home-manager). Vi vay hosts/macmini/home.nix KHONG con dong
    # dotbrave nao.
    dotbrave.enable = true;
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
