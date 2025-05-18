{pkgs, lib, config, ...}:
{
  home.file.".local/share/applications".source = ./applications;
}