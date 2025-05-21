  # imports = [flake-inputs.flatpaks.homeManagerModules.nix-flatpak ];
{
  services.flatpak.packages = [
    "im.riot.Riot"
  ];
}