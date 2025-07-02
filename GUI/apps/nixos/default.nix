{ pkgs, config,... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    discord
    vscode
    telegram-desktop
    localsend
    joplin-desktop
    slack
    thunderbird
    brave
    google-chrome
    kitty
    # chromedriver
    caprine
    rustdesk
    # notion-app-enhanced


  ];
  services.flatpak.packages = [
    { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  ];

}