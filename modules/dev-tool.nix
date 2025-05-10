

{ config
, pkgs
, inputs
, ...
}:
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
        python3
        python3Packages.pip
        python3Packages.pipx
        python3Packages.uv
        nodejs
        nodejs.pkgs.npm
        nodejs.pkgs.yarn
        nodejs.pkgs.nodemon
        nodejs.pkgs.pm2
        yazi
        zoxide
        python312Packages.conda
        atuin
        ncdu
        syncthing 
        pipx
        flatpak
        bitwarden-cli
    ];
}