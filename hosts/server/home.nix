{ pkgs, device, lib, ... }:
{
  imports = [
    ../../home-manager
  ];
  home.shellAliases = {
    update = "nix run github:nix-community/home-manager -- switch --impure -b backup --refresh --flake github:kln-os/nix/main#server";
  };
  modules = {
    dotfiles = {
      btop.enable = true;
      yazi.enable = true;
      ssh.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    pkgs = {
      cli.enable = true;
      dev.enable = true;
    };
    programs = {
      nvim.enable = true;
      bin.enable = true;
      git.enable = true;
    };
    services = {
      syncthing.enable = true;
    };
  };
  home.packages = [
    pkgs.discordchatexporter-cli
  ];
}