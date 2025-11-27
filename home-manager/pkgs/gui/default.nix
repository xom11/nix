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
    # qutebrowser
    # slack
    telegram-desktop
    vlc
    vscode
  ];

  #NOTE: Replace vimiumc with surfingkeys
  programs.chromium = {
    enable = false;
    package = pkgs.brave;
    extensions = [
      {id = "hfjbmagddngcpeloejdejnfgbamkjaeg";} # vimium c
      {id = "nacjakoppgmdcpemlfnfegmlhipddanj";} # pdf for vimium c
    ];
    commandLineArgs = [
      "--enable-features=ParallelDownloading"
      "--extensions-on-chrome-urls"
    ];
  };
}
