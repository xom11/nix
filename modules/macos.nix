{pkgs, ... }:
{
    imports = [
        ./apps/share
        ./apps/macos
        ./git
        # ./gnome
        ./kitty
        ./nvim
        ./tmux
        ./tools
        ./zsh
    ];
}

