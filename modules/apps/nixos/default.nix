{ pkgs, config,... }:

{
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  # The critical missing piece for me
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