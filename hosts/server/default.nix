{ pkgs, device, lib, ... }:
{
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
  modules = {
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      nvim.enable = true;
      git.enable = true;
      tmux.enable = true;
      zsh.enable = true;
      ssh.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
  ];
}