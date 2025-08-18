{ ... }:
{
  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui/dotfiles"
    "gui/fonts"

    "cli/os/macos"
    "cli/programs"
    "cli/pkgs"

    "base"
    "secrets"
  ];

  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
}


