{ pkgs, config,... }:

{

  home.packages = with pkgs; [
    preload
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
    # teamviewer
    # anydesk

  ];
  services.flatpak.packages = [
    { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  ];

}