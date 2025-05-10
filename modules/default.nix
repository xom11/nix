{ inputs, pkgs, config, ... }:

{
    home.stateVersion = "23.11";
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