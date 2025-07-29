{ pkgs, config,... }:

{
  imports = [
    ../desktop
    ../pwa
  ];

  home.packages = with pkgs; [
    bitwarden-desktop
    qutebrowser
    discord
    vscode
    telegram-desktop
    localsend
    slack
    brave
    google-chrome
    kitty
    zathura
    # chromedriver
    caprine
    # notion-app-enhanced
    vlc


  ];
  services.flatpak.packages = [
    # { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  ];
}
