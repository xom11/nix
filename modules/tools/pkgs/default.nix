{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
        neofetch
        fastfetch
        vim
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
        # syncthing 
        docker
        tldr

        # SSH
        openssh
        tailscale
        putty

        # Python
        pipx
        python3
        python3Packages.pip
        # python3Packages.pipx
        # python3Packages.uv
        uv

        # Node.js
        nodejs
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2


    ];
}