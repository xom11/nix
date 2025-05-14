{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
        neofetch
        htop
        htop
        lazygit
        stow
        zip
        unzip
        wget
        curl
        tree
        jq
        fzf
        ripgrep
        fd          #find
        bat
        eza
        gcc
        yazi
        zoxide
        atuin
        ncdu        #disk usage
        syncthing 
        pipx
        tailscale
        docker
        tldr
        thefuck

        # Python
        python3
        python3Packages.pip
        python3Packages.pipx
        python3Packages.uv

        # Node.js
        nodejs
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2

    ];
}