{ ... }:
{
  imports = builtins.map (name: ../../src/home-manager/${name}) [
    "gui"
    "cli"
    "base"
    "secrets"
  ];

  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
}


