{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment = {
      systemPackages = [
        pkgs.ripgrep
        pkgs.fd
        pkgs.hello
        pkgs.cowsay
      ];
    };

  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}