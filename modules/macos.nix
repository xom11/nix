{pkgs, ... }:
{
    imports = [
        ./apps/macos
        ./git
        ./kitty
        ./nvim
        ./tmux
        ./tools
        ./zsh
    ];
}

