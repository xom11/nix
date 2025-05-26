{pkgs, lib, config, ...}:
{
  home.file.".local/share/applications".source = ./applications;
  # home.file.".local/share/icons".source = ./icons;
}