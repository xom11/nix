{
  lib,
  config,
  dotbrave,
  homeDir,
  ...
}: {
  imports = [
    ../../nix-darwin
    dotbrave.darwinModules.default
  ];
  # [pwa] o tang he thong: darwin-rebuild von chay bang root nen viet duoc
  # policy tai /Library/Managed Preferences ma khong can prompt sudo giua
  # activation. Tro toi dung brave.toml ma module home-manager (Task 6)
  # dung -- ca hai phai doc chung mot file.
  services.dotbrave = {
    enable = true;
    config = "${homeDir}/.nix/home-manager/dotfiles/browser/dotbrave/brave.toml";
  };
  modules.nix-darwin = {
    brew.enable = true;
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
