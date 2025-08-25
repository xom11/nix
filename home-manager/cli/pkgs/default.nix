{ config, pkgs, ... }:
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

    # Pass
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

  ];
}
