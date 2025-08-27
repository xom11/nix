{ config, pkgs, lib, device, ... }:

{

  home.packages = with pkgs; [
    fastfetch
    vim
    htop
    btop
    lazygit
    lazydocker
    zip
    unzip
    wget
    curl
    tree
    fzf
    bat
    eza
    yazi
    zoxide
    ncdu
    jq
    gh
    ripgrep
    ansible

    # Secret
    pass
    gnupg
    age

    # Database
    minio-client

    # Rust
    maturin
    rustup

    # Python
    python3
    python3Packages.pip
    uv
    # pipx
    micromamba

    # Node.js
    nodejs.pkgs.npm
    nodejs.pkgs.yarn
    nodejs.pkgs.nodemon
    nodejs.pkgs.pm2

  ] ++ (with pkgs; lib.optionals (device == "macmini") [
    caligula

  ]) ++ (with pkgs; lib.optionals (device == "x1g6") [
    tldr
    gemini-cli
    gcc
    caligula
    
    # i3wm
    autorandr
    feh
    rofi
    bluetui
    xdotool
    xclip
    brightnessctl
    clipmenu
    dragon-drop
    maim

    bitwarden-desktop
    qutebrowser
    discord
    nemo
    vscode
    telegram-desktop
    localsend
    slack
    google-chrome
    kitty
    caprine
    vlc

  ]) ++ (with pkgs; lib.optionals (device == "server") [
    ffmpeg
    discordchatexporter-cli
    xsel

  ]) ++ (with pkgs; lib.optionals (device == "desktop") [

  ])
  ;
}
