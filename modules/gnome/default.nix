{...}:
{
  imports = [
    ./gnome-extensions.nix
    ./gnome-settings.nix
    ./gnome-pkgs.nix
  ];
  home.file.".config/run-or-raise".source = ./run-or-raise;
}