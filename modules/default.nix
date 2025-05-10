{ inputs, pkgs, config, ... }:

{
    imports = [
        # # gui
        # ./firefox
        # ./foot
        # ./eww
        # ./dunst
        # ./hyprland
        # ./wofi

        # # cli
        # ./nvim
        ./zsh
        # ./git
        # ./gpg
        # ./direnv

        # # system
        # ./xdg
	    # ./packages
    ];
}