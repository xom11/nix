
{ config, pkgs, ... }:
let user = builtins.getEnv "SUDO_USER";
in
{
  imports = [
    ../../modules/fonts
    ./homebrew.nix
    ./system.nix
  ];
  environment.systemPackages =[
    pkgs.vim
    ];

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true; 
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = user;
  system.stateVersion = 6;

}