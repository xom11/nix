{ pkgs, config,... }:

{
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
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

}