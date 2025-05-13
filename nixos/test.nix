
{input, config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/configuration.nix
    ];
  
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [bamboo];
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

  services.xserver.enable = true;
  services.xserver.displayManager.sessionPackages = with pkgs; [
    sway
  ];
}