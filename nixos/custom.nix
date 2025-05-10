{ config
, pkgs
, inputs
, lib
, ...
}:
{

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];


  nixpkgs.config.allowUnfreePredicate = (_: true);
  boot.loader.systemd-boot.configurationLimit = 5;
  # Garbage Collector Setting
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 7d";

  environment.systemPackages = with pkgs;
    [
    # AppImage
    kitty
    ibus-engines.bamboo
    xdg-desktop-portal 
    xdg-desktop-portal-gtk
    bitwarden
    discord
    gnome-extension-manager
    vscode
    notion
    microsoft-edge
    telegram-desktop
    brave
    google-chrome

    oh-my-zsh
    zsh-powerlevel10k
    ];
  
   # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.theme = "powerlevel10k/powerlevel10k";
    dotDir = ".config/zsh";
  };

}