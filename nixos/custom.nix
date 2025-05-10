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
    ];
  
   # zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.theme = "powerlevel10k/powerlevel10k";
    ohMyZsh.plugins = [
      "gitfast"
      "history"
      "sudo"
      "kubectl"
      "docker"
      "helm"
    ];
    ohMyZsh.initExtra = ''
      export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store";
      export ZK_NOTEBOOK_DIR="~/stuff/notes";
      export DIRENV_LOG_FORMAT="";
      bindkey '^ ' autosuggest-accept
      edir() { tar -cz $1 | age -p > $1.tar.gz.age && rm -rf $1 &>/dev/null && echo "$1 encrypted" }
      ddir() { age -d $1 | tar -xz && rm -rf $1 &>/dev/null && echo "$1 decrypted" }
    '';
    shellAliases = {
      c = "clear";
      mkdir = "mkdir -vp";
      rm = "rm -rifv";
      mv = "mv -iv";
      cp = "cp -riv";
      cat = "bat --paging=never --style=plain";
      ls = "exa -a --icons";
      tree = "exa --tree --icons";
      nd = "nix develop -c $SHELL";
    };
  };

}