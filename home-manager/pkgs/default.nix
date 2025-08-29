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
    micromamba

    # Node.js
    nodejs.pkgs.npm
    nodejs.pkgs.yarn
    nodejs.pkgs.nodemon
    nodejs.pkgs.pm2

    # Other
    tldr
    ffmpeg

  ] ++ (with pkgs; lib.optionals (device == "macmini") [
    caligula

  ]) ++ (with pkgs; lib.optionals (device == "x1g6") [
    

  ]) ++ (with pkgs; lib.optionals (device == "server") [
    discordchatexporter-cli
    xsel

  ]) ++ (with pkgs; lib.optionals (device == "desktop" || device == "x1g6") [
    gemini-cli
    gcc
    caligula
    
  ])
  ;
}
