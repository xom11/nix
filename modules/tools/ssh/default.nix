{config, pkgs, ...}:
{
  programs.ssh = {
    enable = true;
    extraConfig = builtins.readFile ./config;
  };
}