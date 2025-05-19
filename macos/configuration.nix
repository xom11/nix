{ config, pkgs, ... }:

{
  
  environment.systemPackages =
    [ pkgs.vim
    ];

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true;  # default shell on catalina
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 6;
}