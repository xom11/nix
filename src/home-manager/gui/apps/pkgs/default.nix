{ pkgs, config,... }:

{
  home.packages = with pkgs; [
    bitwarden-desktop
    qutebrowser
    nautilus
    discord
    vscode
    telegram-desktop
    localsend
    slack
    google-chrome
    kitty
    caprine
    vlc
  ];

  # services.flatpak.packages = [
    # { appId = "com.simplenote.Simplenote"; origin = "flathub"; }
  # ];
}
