{ pkgs, config,... }:

{
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
    # chromedriver
    caprine
    # notion-app-enhanced


  ];
  services.flatpak.packages = [
    # { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  ];
  programs.firefox.enable = true;


}