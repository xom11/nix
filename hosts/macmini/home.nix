{ ... }:
{
  imports = [
    ../../src/home-manager
  ];

  home.shellAliases = {
    update = "sudo darwin-rebuild switch --impure --flake ~/.nix#macmini";
  };
}


