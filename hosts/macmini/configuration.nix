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
    launchd = {
      kanata.enable = true;
    };
  };
  nix.settings = {
    max-jobs = "auto";
    cores = 0; # 0 nghĩa là sử dụng tất cả các nhân
  };

  # Enable darwin-specific settings
  # power.sleep = {
  #   computer = "never";
  # };
  homebrew = {
    brews = [
      "redis"
      "postgresql"
      "nginx"
      "httpie"
      "ollama"
      "livekit"
      "ffmpeg@6"
    ];
    casks = [
      "postman"
      "xquartz"
    ];
  };
}
