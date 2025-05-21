
{input, config, pkgs, lib, ... }:
let
  bamboo = pkgs.callPackage ./ibus-bamboo.nix {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/configuration.nix
      ../../modules/fonts
      ./flatpak.nix
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = [
      bamboo
    ];
  };

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "kln";
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;

}