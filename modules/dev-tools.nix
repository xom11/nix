{ config, pkgs, inputs, ...}:
{
    home.packages = with pkgs;[
        neovim
        neofetch
        htop
        git
        tmux
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
        fd
        bat
        eza
        gcc
        yazi
        zoxide
        atuin
        ncdu
        syncthing 
        pipx
        tailscale
        docker

        # Python
        python3
        python3Packages.pip
        python3Packages.pipx
        python3Packages.uv
        conda

        # Node.js
        nodejs
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2

    ];
}