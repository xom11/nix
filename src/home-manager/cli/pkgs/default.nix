{ config, pkgs,  ...}:
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
        yazi
        zoxide
        ncdu
        jq
        gh
        ripgrep
        ansible
        # openssl

        # Database
        minio-client

        # Rust
        maturin
        rustup

        # Python
        python310
        python3Packages.pip
        uv
        micromamba


        # Node.js
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2

    ];
}
