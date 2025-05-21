
{ config, pkgs, ... }:
let user = builtins.getEnv "USER"; in

{
  imports = [
    ../../modules/fonts
    ./homebrew.nix
  ];
  environment.systemPackages =[
    pkgs.vim
    ];

  nix.settings.experimental-features = "nix-command flakes";
  programs.zsh.enable = true; 
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    # Turn off NIX_PATH warnings now that we're using flakes
    # checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 6;
    defaults = {
      dock = {
        autohide = false;
      };

    };
  };
}