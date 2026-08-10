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
    # slack
    telegram-desktop
    vlc
    vscode
  ];

  # Khoi nay DANG TAT (enable = false), giu lai lam khung san cho lan can toi.
  # Hai extension vimium c da bo cung luc go dotfiles/browser/vimiumc
  # (10/08/2026) -- surfingkeys da thay, va no khong cai qua day: extension tu
  # tai configs.js bang URL raw tren GitHub, xem dotfiles/browser/surfingkeys.
  programs.chromium = {
    enable = false;
    package = pkgs.brave;
    commandLineArgs = [
      "--enable-features=ParallelDownloading"
      "--extensions-on-chrome-urls"
    ];
  };
}
