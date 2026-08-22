{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    bitwarden-desktop
    brave
    # caprine
    # deskreen
    # discord # x86_64 only
    # google-chrome # x86_64 only
    kitty
    localsend
    nemo
    # PipeWire/PulseAudio GUI mixer: switch sinks/ports and per-app volume.
    pavucontrol
    # slack
    telegram-desktop
    vlc
    vscode
  ];

  # DISABLED, kept as scaffolding. The vimium-c extensions went with its dotfiles
  # directory; surfingkeys replaced it and is not installed here -- its extension
  # fetches configs.js from a raw GitHub URL instead.
  programs.chromium = {
    enable = false;
    package = pkgs.brave;
    commandLineArgs = [
      "--enable-features=ParallelDownloading"
      "--extensions-on-chrome-urls"
    ];
  };
}
