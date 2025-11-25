{
  pkgs,
  config,
  mkModule,
  ...
}:
mkModule config ./. {
  home.packages = with pkgs; [
    bitwarden-desktop
    # deskreen
    # qutebrowser
    # discord # x86_64 only
    nemo
    vscode
    telegram-desktop
    localsend
    # slack
    # google-chrome # x86_64 only
    kitty
    # caprine
    vlc
    brave
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
