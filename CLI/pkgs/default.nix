{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
        fastfetch
        vim
        htop
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
        gcc
        yazi
        zoxide
        ncdu
        jq
        gh
        openssh

        # Rust
        cargo
        maturin
        rustc

        # Python
        python3
        python3Packages.pip
        uv

        # Node.js
        nodejs
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2

    ];
}